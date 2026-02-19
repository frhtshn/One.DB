-- ================================================================
-- WITHDRAWAL_FAIL: Para çekme başarısız (PSP red — REVERSAL)
-- ================================================================
-- PSP payout başarısız döndüğünde çağrılır.
-- withdrawal_cancel ile aynı mantık: reversal tx ile bakiye
-- geri eklenir. Ayrı fonksiyon çünkü backend'de farklı
-- trigger'lar (PSP fail vs BO/player cancel).
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS wallet.withdrawal_fail(VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION wallet.withdrawal_fail(
    p_idempotency_key VARCHAR(100),
    p_reason          VARCHAR(255) DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_tx             RECORD;
    v_balance        NUMERIC(18,8);
    v_new_balance    NUMERIC(18,8);
    v_bonus_balance  NUMERIC(18,8) := 0;
    v_reversal_id    BIGINT;
    v_currency_code  VARCHAR(20);
BEGIN
    -- İdempotency key ile pending withdrawal tx bul
    SELECT t.id, t.player_id, t.wallet_id, t.amount, t.confirmed_at,
           t.processed_at, t.created_at
    INTO v_tx
    FROM transaction.transactions t
    WHERE t.idempotency_key = p_idempotency_key
      AND t.source = 'PAYMENT'
      AND t.operation_type_id = 1  -- debit
    LIMIT 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.withdrawal-fail.already-confirmed';
    END IF;

    -- Zaten onaylanmış → fail edilemez
    IF v_tx.confirmed_at IS NOT NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.withdrawal-fail.already-confirmed';
    END IF;

    -- Zaten iptal/fail edilmiş → idempotent dönüş kontrolü
    IF v_tx.processed_at IS NOT NULL THEN
        SELECT ws.balance INTO v_balance
        FROM wallet.wallet_snapshots ws
        WHERE ws.wallet_id = v_tx.wallet_id;

        SELECT currency_code INTO v_currency_code
        FROM wallet.wallets WHERE id = v_tx.wallet_id;

        SELECT COALESCE(ws.balance, 0) INTO v_bonus_balance
        FROM wallet.wallets w
        JOIN wallet.wallet_snapshots ws ON ws.wallet_id = w.id
        WHERE w.player_id = v_tx.player_id
          AND w.wallet_type = 'BONUS'
          AND w.currency_code = v_currency_code
          AND w.status = 1;

        RETURN jsonb_build_object(
            'transactionId', v_tx.id,
            'cash', v_balance,
            'bonus', COALESCE(v_bonus_balance, 0),
            'currency', v_currency_code
        );
    END IF;

    -- Currency code al
    SELECT currency_code INTO v_currency_code
    FROM wallet.wallets WHERE id = v_tx.wallet_id;

    -- Orijinal tx'i fail olarak işaretle
    UPDATE transaction.transactions
    SET processed_at = NOW(),
        description = 'FAILED: ' || COALESCE(p_reason, 'PSP failure')
    WHERE id = v_tx.id
      AND created_at = v_tx.created_at;

    -- Wallet snapshot kilitle
    SELECT ws.balance INTO v_balance
    FROM wallet.wallet_snapshots ws
    WHERE ws.wallet_id = v_tx.wallet_id
    FOR UPDATE;

    -- Bakiye geri ekle (reversal)
    v_new_balance := v_balance + v_tx.amount;

    -- Reversal transaction oluştur
    INSERT INTO transaction.transactions (
        player_id, wallet_id,
        transaction_type_id, operation_type_id,
        amount, balance_after,
        related_transaction_id,
        source, description, metadata,
        requested_at, confirmed_at, created_at
    ) VALUES (
        v_tx.player_id, v_tx.wallet_id,
        91, 2,  -- withdrawal.reversal, credit
        v_tx.amount, v_new_balance,
        v_tx.id,
        'PAYMENT', 'Withdrawal failure reversal: ' || COALESCE(p_reason, ''),
        jsonb_build_object('originalTransactionId', v_tx.id, 'reason', COALESCE(p_reason, '')),
        NOW(), NOW(), NOW()
    )
    RETURNING id INTO v_reversal_id;

    -- Wallet snapshot güncelle
    UPDATE wallet.wallet_snapshots SET
        balance = v_new_balance,
        last_transaction_id = v_reversal_id,
        updated_at = NOW()
    WHERE wallet_id = v_tx.wallet_id;

    -- Bonus bakiye oku
    SELECT COALESCE(ws.balance, 0) INTO v_bonus_balance
    FROM wallet.wallets w
    JOIN wallet.wallet_snapshots ws ON ws.wallet_id = w.id
    WHERE w.player_id = v_tx.player_id
      AND w.wallet_type = 'BONUS'
      AND w.currency_code = v_currency_code
      AND w.status = 1;

    -- Sonuç dön
    RETURN jsonb_build_object(
        'transactionId', v_reversal_id,
        'cash', v_new_balance,
        'bonus', COALESCE(v_bonus_balance, 0),
        'currency', v_currency_code
    );
END;
$$;

COMMENT ON FUNCTION wallet.withdrawal_fail IS 'Handles a failed withdrawal (PSP rejection) by creating a reversal transaction that credits the wallet back. Cannot fail an already confirmed withdrawal.';

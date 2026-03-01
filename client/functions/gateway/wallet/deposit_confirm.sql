-- ================================================================
-- DEPOSIT_CONFIRM: Para yatırma onayla (CREDIT)
-- ================================================================
-- PSP callback sonrası çağrılır. PENDING deposit transaction'ı
-- onaylar ve wallet bakiyesini artırır. İdempotent: zaten
-- onaylanmış tx için mevcut sonucu döner (exception yok).
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS wallet.deposit_confirm(VARCHAR, BIGINT, VARCHAR, TEXT);

CREATE OR REPLACE FUNCTION wallet.deposit_confirm(
    p_idempotency_key       VARCHAR(100),
    p_player_id             BIGINT DEFAULT NULL,
    p_external_reference_id VARCHAR(100) DEFAULT NULL,
    p_metadata              TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_tx             RECORD;
    v_wallet_id      BIGINT;
    v_balance        NUMERIC(18,8);
    v_new_balance    NUMERIC(18,8);
    v_bonus_balance  NUMERIC(18,8) := 0;
    v_metadata_json  JSONB;
BEGIN
    -- İdempotency key ile transaction bul
    SELECT t.id, t.player_id, t.wallet_id, t.amount, t.balance_after,
           t.confirmed_at, t.external_reference_id, t.metadata
    INTO v_tx
    FROM transaction.transactions t
    WHERE t.idempotency_key = p_idempotency_key
      AND t.source = 'PAYMENT'
      AND t.operation_type_id = 2  -- credit
    LIMIT 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.deposit-confirm.transaction-not-found';
    END IF;

    -- Zaten onaylanmış → idempotent dönüş (exception yok)
    IF v_tx.confirmed_at IS NOT NULL THEN
        SELECT COALESCE(ws.balance, 0) INTO v_bonus_balance
        FROM wallet.wallets w
        JOIN wallet.wallet_snapshots ws ON ws.wallet_id = w.id
        WHERE w.player_id = v_tx.player_id
          AND w.wallet_type = 'BONUS'
          AND w.currency_code = (
              SELECT currency_code FROM wallet.wallets WHERE id = v_tx.wallet_id
          )
          AND w.status = 1;

        RETURN jsonb_build_object(
            'transactionId', v_tx.id,
            'cash', v_tx.balance_after,
            'bonus', COALESCE(v_bonus_balance, 0),
            'currency', (SELECT currency_code FROM wallet.wallets WHERE id = v_tx.wallet_id)
        );
    END IF;

    -- Player ID kontrolü (opsiyonel güvenlik)
    IF p_player_id IS NOT NULL AND p_player_id != v_tx.player_id THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.deposit-confirm.player-mismatch';
    END IF;

    -- Wallet snapshot kilitle
    SELECT ws.balance INTO v_balance
    FROM wallet.wallet_snapshots ws
    WHERE ws.wallet_id = v_tx.wallet_id
    FOR UPDATE;

    -- Yeni bakiye hesapla (credit)
    v_new_balance := v_balance + v_tx.amount;

    -- Metadata birleştir
    v_metadata_json := COALESCE(v_tx.metadata, '{}'::JSONB);
    IF p_metadata IS NOT NULL THEN
        v_metadata_json := v_metadata_json || p_metadata::JSONB;
    END IF;

    -- Transaction güncelle
    UPDATE transaction.transactions
    SET confirmed_at = NOW(),
        balance_after = v_new_balance,
        external_reference_id = COALESCE(p_external_reference_id, external_reference_id),
        metadata = v_metadata_json,
        processed_at = NOW()
    WHERE id = v_tx.id
      AND created_at = (SELECT created_at FROM transaction.transactions WHERE id = v_tx.id AND idempotency_key = p_idempotency_key LIMIT 1);

    -- Wallet snapshot güncelle
    UPDATE wallet.wallet_snapshots SET
        balance = v_new_balance,
        last_transaction_id = v_tx.id,
        updated_at = NOW()
    WHERE wallet_id = v_tx.wallet_id;

    -- Bonus bakiye oku
    SELECT COALESCE(ws.balance, 0) INTO v_bonus_balance
    FROM wallet.wallets w
    JOIN wallet.wallet_snapshots ws ON ws.wallet_id = w.id
    WHERE w.player_id = v_tx.player_id
      AND w.wallet_type = 'BONUS'
      AND w.currency_code = (
          SELECT currency_code FROM wallet.wallets WHERE id = v_tx.wallet_id
      )
      AND w.status = 1;

    -- Sonuç dön
    RETURN jsonb_build_object(
        'transactionId', v_tx.id,
        'cash', v_new_balance,
        'bonus', COALESCE(v_bonus_balance, 0),
        'currency', (SELECT currency_code FROM wallet.wallets WHERE id = v_tx.wallet_id)
    );
END;
$$;

COMMENT ON FUNCTION wallet.deposit_confirm IS 'Confirms a pending deposit by crediting the wallet. Idempotent: returns cached result for already-confirmed transactions without raising an exception.';

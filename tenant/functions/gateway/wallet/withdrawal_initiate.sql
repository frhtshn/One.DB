-- ================================================================
-- WITHDRAWAL_INITIATE: Para çekme başlat (DEBIT — HEMEN)
-- ================================================================
-- Withdrawal akışının ilk adımı. Wallet bakiyesi HEMEN düşer
-- (çift harcama önlemi). PENDING transaction oluşturulur.
-- Bonus çevrim kontrolü yapılır. İptal/red durumunda
-- withdrawal_cancel/fail ile bakiye geri eklenir.
-- İdempotent: aynı key ile tekrar çağrılırsa mevcut sonucu döner.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS wallet.withdrawal_initiate(BIGINT, VARCHAR, DECIMAL, DECIMAL, VARCHAR, SMALLINT, VARCHAR, TEXT);

CREATE OR REPLACE FUNCTION wallet.withdrawal_initiate(
    p_player_id            BIGINT,
    p_currency_code        VARCHAR(20),
    p_amount               DECIMAL(18,8),
    p_fee_amount           DECIMAL(18,8) DEFAULT 0,
    p_idempotency_key      VARCHAR(100) DEFAULT NULL,
    p_transaction_type_id  SMALLINT DEFAULT 85,
    p_external_reference_id VARCHAR(100) DEFAULT NULL,
    p_metadata             TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_existing_tx      RECORD;
    v_player_status    SMALLINT;
    v_wallet_id        BIGINT;
    v_balance          NUMERIC(18,8);
    v_new_balance      NUMERIC(18,8);
    v_bonus_balance    NUMERIC(18,8) := 0;
    v_total_debit      NUMERIC(18,8);
    v_tx_id            BIGINT;
    v_metadata_json    JSONB;
    v_has_active_wager BOOLEAN;
BEGIN
    -- Zorunlu alan kontrolleri
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.deposit.player-required';
    END IF;

    IF p_amount IS NULL OR p_amount <= 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.deposit.invalid-amount';
    END IF;

    IF p_idempotency_key IS NULL OR TRIM(p_idempotency_key) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.deposit.idempotency-required';
    END IF;

    -- İdempotency kontrolü
    SELECT t.id, t.balance_after, t.wallet_id
    INTO v_existing_tx
    FROM transaction.transactions t
    WHERE t.idempotency_key = p_idempotency_key
    LIMIT 1;

    IF FOUND THEN
        SELECT COALESCE(ws.balance, 0) INTO v_bonus_balance
        FROM wallet.wallets w
        JOIN wallet.wallet_snapshots ws ON ws.wallet_id = w.id
        WHERE w.player_id = p_player_id
          AND w.wallet_type = 'BONUS'
          AND w.currency_code = p_currency_code
          AND w.status = 1;

        RETURN jsonb_build_object(
            'transactionId', v_existing_tx.id,
            'cash', v_existing_tx.balance_after,
            'bonus', COALESCE(v_bonus_balance, 0),
            'currency', p_currency_code
        );
    END IF;

    -- Player durum kontrolü
    SELECT status INTO v_player_status
    FROM auth.players
    WHERE id = p_player_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.deposit.wallet-not-found';
    END IF;

    IF v_player_status != 1 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.deposit.player-not-active';
    END IF;

    -- REAL wallet bul
    SELECT w.id INTO v_wallet_id
    FROM wallet.wallets w
    WHERE w.player_id = p_player_id
      AND w.wallet_type = 'REAL'
      AND w.currency_code = p_currency_code
      AND w.status = 1;

    IF v_wallet_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.deposit.wallet-not-found';
    END IF;

    -- Bonus çevrim kontrolü (basit)
    SELECT EXISTS(
        SELECT 1 FROM bonus.bonus_awards ba
        WHERE ba.player_id = p_player_id
          AND ba.status = 'active'
          AND ba.is_wagering_complete = false
    ) INTO v_has_active_wager;

    IF v_has_active_wager THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.withdrawal.active-wagering-incomplete';
    END IF;

    -- Wallet snapshot kilitle
    SELECT ws.balance INTO v_balance
    FROM wallet.wallet_snapshots ws
    WHERE ws.wallet_id = v_wallet_id
    FOR UPDATE;

    -- Total debit hesapla (amount + fee)
    v_total_debit := p_amount + COALESCE(p_fee_amount, 0);

    -- Bakiye kontrolü
    IF v_balance < v_total_debit THEN
        RAISE EXCEPTION USING ERRCODE = 'P0402', MESSAGE = 'error.withdrawal.insufficient-balance';
    END IF;

    -- Yeni bakiye hesapla (debit)
    v_new_balance := v_balance - v_total_debit;

    -- Metadata hazırla
    v_metadata_json := CASE WHEN p_metadata IS NOT NULL THEN p_metadata::JSONB ELSE '{}'::JSONB END;
    v_metadata_json := v_metadata_json || jsonb_build_object(
        'feeAmount', COALESCE(p_fee_amount, 0),
        'netAmount', p_amount,
        'totalDebit', v_total_debit
    );

    -- PENDING transaction oluştur (bakiye HEMEN düşer)
    INSERT INTO transaction.transactions (
        player_id, wallet_id,
        transaction_type_id, operation_type_id,
        amount, balance_after,
        idempotency_key, external_reference_id,
        source, metadata,
        requested_at, created_at
    ) VALUES (
        p_player_id, v_wallet_id,
        p_transaction_type_id, 1,  -- debit
        v_total_debit, v_new_balance,
        p_idempotency_key, p_external_reference_id,
        'PAYMENT', v_metadata_json,
        NOW(), NOW()
    )
    RETURNING id INTO v_tx_id;

    -- Wallet snapshot güncelle
    UPDATE wallet.wallet_snapshots SET
        balance = v_new_balance,
        last_transaction_id = v_tx_id,
        updated_at = NOW()
    WHERE wallet_id = v_wallet_id;

    -- Bonus bakiye oku
    SELECT COALESCE(ws.balance, 0) INTO v_bonus_balance
    FROM wallet.wallets w
    JOIN wallet.wallet_snapshots ws ON ws.wallet_id = w.id
    WHERE w.player_id = p_player_id
      AND w.wallet_type = 'BONUS'
      AND w.currency_code = p_currency_code
      AND w.status = 1;

    -- Sonuç dön
    RETURN jsonb_build_object(
        'transactionId', v_tx_id,
        'cash', v_new_balance,
        'bonus', COALESCE(v_bonus_balance, 0),
        'currency', p_currency_code
    );
END;
$$;

COMMENT ON FUNCTION wallet.withdrawal_initiate IS 'Initiates a withdrawal by immediately debiting the wallet (prevents double-spend). Creates PENDING transaction. Checks bonus wagering requirements. Use withdrawal_confirm to finalize or withdrawal_cancel/fail to reverse.';

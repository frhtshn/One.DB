-- ================================================================
-- ADJUSTMENT_PROCESS: Düzeltme işlemi (CREDIT veya DEBIT)
-- ================================================================
-- Provider tarafından gelen düzeltme işlemleri. Pozitif tutar
-- credit (bakiye artar), negatif tutar debit (bakiye azalır).
-- PP adjustment endpoint'i için (sadece Live Casino).
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS wallet.adjustment_process(BIGINT, VARCHAR, DECIMAL, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, TEXT);

CREATE OR REPLACE FUNCTION wallet.adjustment_process(
    p_player_id BIGINT,
    p_currency_code VARCHAR(20),
    p_amount DECIMAL(18,8),
    p_idempotency_key VARCHAR(100),
    p_external_reference_id VARCHAR(100) DEFAULT NULL,
    p_provider_code VARCHAR(50) DEFAULT NULL,
    p_round_id VARCHAR(100) DEFAULT NULL,
    p_game_code VARCHAR(100) DEFAULT NULL,
    p_metadata TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_existing_tx RECORD;
    v_player_status SMALLINT;
    v_wallet_id BIGINT;
    v_balance NUMERIC(18,8);
    v_new_balance NUMERIC(18,8);
    v_bonus_balance NUMERIC(18,8) := 0;
    v_tx_id BIGINT;
    v_op_type SMALLINT;
    v_abs_amount NUMERIC(18,8);
    v_metadata_json JSONB;
BEGIN
    -- Zorunlu alan kontrolleri
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.player-required';
    END IF;

    IF p_amount IS NULL OR p_amount = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.wallet.amount-required';
    END IF;

    IF p_idempotency_key IS NULL OR TRIM(p_idempotency_key) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.wallet.idempotency-key-required';
    END IF;

    -- İşlem yönü belirle
    IF p_amount > 0 THEN
        v_op_type := 2;  -- credit
        v_abs_amount := p_amount;
    ELSE
        v_op_type := 1;  -- debit
        v_abs_amount := ABS(p_amount);
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
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.wallet.player-not-found';
    END IF;

    IF v_player_status != 1 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.wallet.player-frozen';
    END IF;

    -- REAL wallet bul
    SELECT w.id INTO v_wallet_id
    FROM wallet.wallets w
    WHERE w.player_id = p_player_id
      AND w.wallet_type = 'REAL'
      AND w.currency_code = p_currency_code
      AND w.status = 1;

    IF v_wallet_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.wallet.wallet-not-found';
    END IF;

    -- Wallet snapshot kilitle
    SELECT ws.balance INTO v_balance
    FROM wallet.wallet_snapshots ws
    WHERE ws.wallet_id = v_wallet_id
    FOR UPDATE;

    -- Debit için bakiye kontrolü
    IF v_op_type = 1 AND v_balance < v_abs_amount THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.wallet.insufficient-balance';
    END IF;

    -- Yeni bakiye hesapla
    IF v_op_type = 2 THEN
        v_new_balance := v_balance + v_abs_amount;
    ELSE
        v_new_balance := v_balance - v_abs_amount;
    END IF;

    -- Metadata hazırla
    v_metadata_json := CASE WHEN p_metadata IS NOT NULL THEN p_metadata::JSONB ELSE '{}'::JSONB END;
    v_metadata_json := v_metadata_json || jsonb_build_object(
        'gameCode', p_game_code,
        'roundId', p_round_id,
        'providerCode', p_provider_code
    );

    -- Transaction kaydı oluştur
    INSERT INTO transaction.transactions (
        player_id, wallet_id,
        transaction_type_id, operation_type_id,
        amount, balance_after,
        idempotency_key, external_reference_id,
        source, metadata, created_at
    ) VALUES (
        p_player_id, v_wallet_id,
        26, v_op_type,
        v_abs_amount, v_new_balance,
        p_idempotency_key, p_external_reference_id,
        'GAME', v_metadata_json, NOW()
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

    RETURN jsonb_build_object(
        'transactionId', v_tx_id,
        'cash', v_new_balance,
        'bonus', COALESCE(v_bonus_balance, 0),
        'currency', p_currency_code
    );
END;
$$;

COMMENT ON FUNCTION wallet.adjustment_process IS 'Processes a provider adjustment. Positive amount = credit, negative = debit with balance check. Uses transaction_type_id=26. Idempotent.';

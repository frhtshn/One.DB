-- ================================================================
-- ROLLBACK_PROCESS: Bahis iadesi / kazanç geri alma
-- ================================================================
-- Hem bet refund (PP) hem win rollback (Hub88) destekler.
-- Orijinal tx bulunamazsa başarılı döner (PP+Hub88 spec).
-- Zaten rollback edilmişse mevcut bakiyeyi döner.
-- Orijinal debit ise credit, orijinal credit ise debit yapar.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS wallet.rollback_process(BIGINT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, SMALLINT, TEXT);

CREATE OR REPLACE FUNCTION wallet.rollback_process(
    p_player_id BIGINT,
    p_currency_code VARCHAR(20),
    p_idempotency_key VARCHAR(100),
    p_original_reference VARCHAR(100),
    p_external_reference_id VARCHAR(100) DEFAULT NULL,
    p_provider_code VARCHAR(50) DEFAULT NULL,
    p_round_id VARCHAR(100) DEFAULT NULL,
    p_transaction_type_id SMALLINT DEFAULT 60,
    p_metadata TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_existing_tx RECORD;
    v_original_tx RECORD;
    v_wallet_id BIGINT;
    v_balance NUMERIC(18,8);
    v_new_balance NUMERIC(18,8);
    v_bonus_balance NUMERIC(18,8) := 0;
    v_tx_id BIGINT;
    v_rollback_op_type SMALLINT;
    v_rollback_tx_type SMALLINT;
    v_rollback_amount NUMERIC(18,8);
    v_metadata_json JSONB;
BEGIN
    -- Zorunlu alan kontrolleri
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.player-required';
    END IF;

    IF p_idempotency_key IS NULL OR TRIM(p_idempotency_key) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.wallet.idempotency-key-required';
    END IF;

    -- İdempotency kontrolü (rollback'in kendisi için)
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

    -- REAL wallet bul
    SELECT w.id INTO v_wallet_id
    FROM wallet.wallets w
    WHERE w.player_id = p_player_id
      AND w.wallet_type = 'REAL'
      AND w.currency_code = p_currency_code
      AND w.status = 1;

    -- Wallet yoksa da başarılı dön (bakiye 0)
    IF v_wallet_id IS NULL THEN
        SELECT COALESCE(ws.balance, 0) INTO v_bonus_balance
        FROM wallet.wallets w
        JOIN wallet.wallet_snapshots ws ON ws.wallet_id = w.id
        WHERE w.player_id = p_player_id
          AND w.wallet_type = 'BONUS'
          AND w.currency_code = p_currency_code
          AND w.status = 1;

        RETURN jsonb_build_object(
            'transactionId', 0,
            'cash', 0,
            'bonus', COALESCE(v_bonus_balance, 0),
            'currency', p_currency_code
        );
    END IF;

    -- Orijinal transaction ara
    SELECT t.id, t.operation_type_id, t.amount, t.wallet_id, t.created_at
    INTO v_original_tx
    FROM transaction.transactions t
    WHERE (t.external_reference_id = p_original_reference OR t.idempotency_key = p_original_reference)
      AND t.player_id = p_player_id
    ORDER BY t.created_at DESC
    LIMIT 1;

    -- Orijinal bulunamazsa → başarılı dön (PP+Hub88 spec)
    IF NOT FOUND THEN
        SELECT ws.balance INTO v_balance
        FROM wallet.wallet_snapshots ws
        WHERE ws.wallet_id = v_wallet_id;

        SELECT COALESCE(ws.balance, 0) INTO v_bonus_balance
        FROM wallet.wallets w
        JOIN wallet.wallet_snapshots ws ON ws.wallet_id = w.id
        WHERE w.player_id = p_player_id
          AND w.wallet_type = 'BONUS'
          AND w.currency_code = p_currency_code
          AND w.status = 1;

        RETURN jsonb_build_object(
            'transactionId', 0,
            'cash', COALESCE(v_balance, 0),
            'bonus', COALESCE(v_bonus_balance, 0),
            'currency', p_currency_code
        );
    END IF;

    -- Zaten rollback edilmiş mi kontrol et
    IF EXISTS (
        SELECT 1 FROM transaction.transactions t
        WHERE t.related_transaction_id = v_original_tx.id
          AND t.source = 'GAME'
          AND t.transaction_type_id IN (60, 61, 62, 63)
        LIMIT 1
    ) THEN
        SELECT ws.balance INTO v_balance
        FROM wallet.wallet_snapshots ws
        WHERE ws.wallet_id = v_wallet_id;

        SELECT COALESCE(ws.balance, 0) INTO v_bonus_balance
        FROM wallet.wallets w
        JOIN wallet.wallet_snapshots ws ON ws.wallet_id = w.id
        WHERE w.player_id = p_player_id
          AND w.wallet_type = 'BONUS'
          AND w.currency_code = p_currency_code
          AND w.status = 1;

        RETURN jsonb_build_object(
            'transactionId', 0,
            'cash', COALESCE(v_balance, 0),
            'bonus', COALESCE(v_bonus_balance, 0),
            'currency', p_currency_code
        );
    END IF;

    -- Ters işlem belirle
    v_rollback_amount := v_original_tx.amount;

    IF v_original_tx.operation_type_id = 1 THEN
        -- Orijinal debit (bet) → credit geri ekle
        v_rollback_op_type := 2;
        v_rollback_tx_type := p_transaction_type_id;
    ELSE
        -- Orijinal credit (win) → debit geri al
        v_rollback_op_type := 1;
        v_rollback_tx_type := 63;
    END IF;

    -- Wallet snapshot kilitle
    SELECT ws.balance INTO v_balance
    FROM wallet.wallet_snapshots ws
    WHERE ws.wallet_id = v_wallet_id
    FOR UPDATE;

    -- Debit (win rollback) için bakiye kontrolü
    IF v_rollback_op_type = 1 AND v_balance < v_rollback_amount THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.wallet.insufficient-balance';
    END IF;

    -- Yeni bakiye hesapla
    IF v_rollback_op_type = 2 THEN
        v_new_balance := v_balance + v_rollback_amount;
    ELSE
        v_new_balance := v_balance - v_rollback_amount;
    END IF;

    -- Metadata hazırla
    v_metadata_json := CASE WHEN p_metadata IS NOT NULL THEN p_metadata::JSONB ELSE '{}'::JSONB END;
    v_metadata_json := v_metadata_json || jsonb_build_object(
        'roundId', p_round_id,
        'providerCode', p_provider_code,
        'originalTransactionId', v_original_tx.id
    );

    -- Rollback transaction kaydı
    INSERT INTO transaction.transactions (
        player_id, wallet_id,
        transaction_type_id, operation_type_id,
        amount, balance_after,
        related_transaction_id,
        idempotency_key, external_reference_id,
        source, metadata, created_at
    ) VALUES (
        p_player_id, v_wallet_id,
        v_rollback_tx_type, v_rollback_op_type,
        v_rollback_amount, v_new_balance,
        v_original_tx.id,
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

COMMENT ON FUNCTION wallet.rollback_process IS 'Reverses a bet (refund/credit) or win (rollback/debit). Returns success even if original transaction not found (per PP/Hub88 spec). Idempotent and duplicate-rollback safe.';

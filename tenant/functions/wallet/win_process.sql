-- ================================================================
-- WIN_PROCESS: Kazanç işlemi (CREDIT)
-- ================================================================
-- REAL wallet'a kazanç ekler. Bakiye kontrolü gerekmez (credit
-- her zaman başarılı). amount=0 geçerli (kayıp round kaydı).
-- p_reference_transaction_key ile orijinal bet'e bağlantı
-- kurulabilir (Hub88 gönderir, PP göndermez).
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS wallet.win_process(BIGINT, VARCHAR, DECIMAL, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, SMALLINT, TEXT);

CREATE OR REPLACE FUNCTION wallet.win_process(
    p_player_id BIGINT,
    p_currency_code VARCHAR(20),
    p_amount DECIMAL(18,8),
    p_idempotency_key VARCHAR(100),
    p_external_reference_id VARCHAR(100) DEFAULT NULL,
    p_reference_transaction_key VARCHAR(100) DEFAULT NULL,
    p_game_code VARCHAR(100) DEFAULT NULL,
    p_provider_code VARCHAR(50) DEFAULT NULL,
    p_round_id VARCHAR(100) DEFAULT NULL,
    p_transaction_type_id SMALLINT DEFAULT 12,
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
    v_related_tx_id BIGINT;
    v_metadata_json JSONB;
BEGIN
    -- Zorunlu alan kontrolleri
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.player-required';
    END IF;

    IF p_amount IS NULL OR p_amount < 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.wallet.amount-required';
    END IF;

    IF p_idempotency_key IS NULL OR TRIM(p_idempotency_key) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.wallet.idempotency-key-required';
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

    -- Yeni bakiye hesapla (credit — bakiye kontrolü yok)
    v_new_balance := v_balance + p_amount;

    -- Referans transaction bul (Hub88 gönderir, PP göndermez)
    IF p_reference_transaction_key IS NOT NULL AND TRIM(p_reference_transaction_key) != '' THEN
        SELECT t.id INTO v_related_tx_id
        FROM transaction.transactions t
        WHERE t.idempotency_key = p_reference_transaction_key
          AND t.player_id = p_player_id
        LIMIT 1;
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
        related_transaction_id,
        idempotency_key, external_reference_id,
        source, metadata, created_at
    ) VALUES (
        p_player_id, v_wallet_id,
        p_transaction_type_id, 2,
        p_amount, v_new_balance,
        v_related_tx_id,
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

COMMENT ON FUNCTION wallet.win_process IS 'Processes a win by crediting the REAL wallet. Supports zero-amount wins for loss rounds. Optional reference linking to original bet transaction via idempotency key.';

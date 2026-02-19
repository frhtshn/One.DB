-- ================================================================
-- DEPOSIT_INITIATE: Para yatırma başlat (PENDING)
-- ================================================================
-- PSP deposit akışının ilk adımı. PENDING transaction oluşturur,
-- wallet bakiyesi DEĞİŞMEZ. PSP onayı (deposit_confirm) sonrası
-- bakiye artar. İdempotent: aynı key ile tekrar çağrılırsa
-- mevcut sonucu döner. Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS wallet.deposit_initiate(BIGINT, VARCHAR, DECIMAL, VARCHAR, SMALLINT, VARCHAR, TEXT);

CREATE OR REPLACE FUNCTION wallet.deposit_initiate(
    p_player_id            BIGINT,
    p_currency_code        VARCHAR(20),
    p_amount               DECIMAL(18,8),
    p_idempotency_key      VARCHAR(100),
    p_transaction_type_id  SMALLINT DEFAULT 80,
    p_external_reference_id VARCHAR(100) DEFAULT NULL,
    p_metadata             TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_existing_tx     RECORD;
    v_player_status   SMALLINT;
    v_wallet_id       BIGINT;
    v_balance         NUMERIC(18,8);
    v_bonus_balance   NUMERIC(18,8) := 0;
    v_tx_id           BIGINT;
    v_metadata_json   JSONB;
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
        -- Mevcut işlemin sonucunu dön
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

    -- Mevcut bakiyeyi oku (FOR UPDATE YOK — bakiye değişmeyecek)
    SELECT ws.balance INTO v_balance
    FROM wallet.wallet_snapshots ws
    WHERE ws.wallet_id = v_wallet_id;

    -- Metadata hazırla
    v_metadata_json := CASE WHEN p_metadata IS NOT NULL THEN p_metadata::JSONB ELSE '{}'::JSONB END;

    -- PENDING transaction oluştur (bakiye DEĞİŞMEZ)
    INSERT INTO transaction.transactions (
        player_id, wallet_id,
        transaction_type_id, operation_type_id,
        amount, balance_after,
        idempotency_key, external_reference_id,
        source, metadata,
        requested_at, created_at
    ) VALUES (
        p_player_id, v_wallet_id,
        p_transaction_type_id, 2,  -- credit
        p_amount, v_balance,       -- balance_after = mevcut bakiye (değişmez)
        p_idempotency_key, p_external_reference_id,
        'PAYMENT', v_metadata_json,
        NOW(), NOW()
    )
    RETURNING id INTO v_tx_id;

    -- Bonus bakiye oku (response için)
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
        'cash', v_balance,
        'bonus', COALESCE(v_bonus_balance, 0),
        'currency', p_currency_code
    );
END;
$$;

COMMENT ON FUNCTION wallet.deposit_initiate IS 'Initiates a deposit by creating a PENDING transaction. Wallet balance does NOT change. Idempotent via idempotency_key. Requires deposit_confirm to actually credit the wallet.';

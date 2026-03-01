-- ================================================================
-- WALLET_CREATE: Oyuncu cüzdanı oluştur
-- ================================================================
-- REAL ve BONUS cüzdanlarını idempotent olarak oluşturur.
-- ON CONFLICT ile tekrar çağrılsa hata vermez.
-- Kullanım: aktivasyon, çoklu para birimi, kripto depo.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS wallet.wallet_create(BIGINT, VARCHAR, SMALLINT);

CREATE OR REPLACE FUNCTION wallet.wallet_create(
    p_player_id     BIGINT,
    p_currency_code VARCHAR(20),
    p_currency_type SMALLINT DEFAULT 1
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_real_wallet_id  BIGINT;
    v_bonus_wallet_id BIGINT;
    v_wallets         JSONB;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.wallet.player-required';
    END IF;

    IF p_currency_code IS NULL OR TRIM(p_currency_code) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.wallet.currency-required';
    END IF;

    -- Oyuncu kontrolü (aktif veya beklemede olmalı)
    IF NOT EXISTS (SELECT 1 FROM auth.players WHERE id = p_player_id AND status IN (0, 1)) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.wallet.player-not-active';
    END IF;

    -- REAL cüzdan oluştur (idempotent)
    INSERT INTO wallet.wallets (player_id, wallet_type, currency_type, currency_code, is_default)
    VALUES (p_player_id, 'REAL', p_currency_type, p_currency_code, TRUE)
    ON CONFLICT (player_id, wallet_type, currency_code) DO NOTHING
    RETURNING id INTO v_real_wallet_id;

    -- Yeni oluştuysa snapshot oluştur
    IF v_real_wallet_id IS NOT NULL THEN
        INSERT INTO wallet.wallet_snapshots (wallet_id, balance, last_transaction_id)
        VALUES (v_real_wallet_id, 0, 0);
    END IF;

    -- BONUS cüzdan oluştur (idempotent)
    INSERT INTO wallet.wallets (player_id, wallet_type, currency_type, currency_code, is_default)
    VALUES (p_player_id, 'BONUS', p_currency_type, p_currency_code, FALSE)
    ON CONFLICT (player_id, wallet_type, currency_code) DO NOTHING
    RETURNING id INTO v_bonus_wallet_id;

    -- Yeni oluştuysa snapshot oluştur
    IF v_bonus_wallet_id IS NOT NULL THEN
        INSERT INTO wallet.wallet_snapshots (wallet_id, balance, last_transaction_id)
        VALUES (v_bonus_wallet_id, 0, 0);
    END IF;

    -- Mevcut cüzdanları döndür
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'walletId', w.id,
            'walletType', w.wallet_type,
            'balance', ws.balance,
            'isDefault', w.is_default
        ) ORDER BY w.wallet_type
    ), '[]'::jsonb)
    INTO v_wallets
    FROM wallet.wallets w
    LEFT JOIN wallet.wallet_snapshots ws ON ws.wallet_id = w.id
    WHERE w.player_id = p_player_id
      AND w.currency_code = p_currency_code;

    RETURN jsonb_build_object(
        'playerId', p_player_id,
        'currencyCode', p_currency_code,
        'wallets', v_wallets
    );
END;
$$;

COMMENT ON FUNCTION wallet.wallet_create IS 'Creates REAL and BONUS wallets for a player. Idempotent via ON CONFLICT. Returns wallet info with balances.';

-- ================================================================
-- GAME_LIMIT_UPSERT: Oyun limiti ekle/güncelle
-- ================================================================
-- (game_id, currency_code) bazlı UPSERT.
-- Client override olarak kaydedilir.
-- Auth-agnostic.
-- ================================================================

DROP FUNCTION IF EXISTS game.game_limit_upsert(BIGINT, VARCHAR, SMALLINT, DECIMAL, DECIMAL, DECIMAL, DECIMAL);

CREATE OR REPLACE FUNCTION game.game_limit_upsert(
    p_game_id BIGINT,
    p_currency_code VARCHAR(20),
    p_currency_type SMALLINT DEFAULT 1,
    p_min_bet DECIMAL(18,8) DEFAULT NULL,
    p_max_bet DECIMAL(18,8) DEFAULT NULL,
    p_default_bet DECIMAL(18,8) DEFAULT NULL,
    p_max_win DECIMAL(18,8) DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Parametre kontrolleri
    IF p_game_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.id-required';
    END IF;

    IF p_currency_code IS NULL OR TRIM(p_currency_code) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.currency-code-required';
    END IF;

    IF p_min_bet IS NULL OR p_max_bet IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.bet-limits-required';
    END IF;

    -- game_settings'te mevcut olmalı
    IF NOT EXISTS(SELECT 1 FROM game.game_settings WHERE game_id = p_game_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.game.not-found';
    END IF;

    -- UPSERT
    INSERT INTO game.game_limits (
        game_id, currency_code, currency_type,
        min_bet, max_bet, default_bet, max_win,
        is_active, created_at, updated_at
    ) VALUES (
        p_game_id,
        UPPER(TRIM(p_currency_code)),
        COALESCE(p_currency_type, 1),
        p_min_bet,
        p_max_bet,
        p_default_bet,
        p_max_win,
        true,
        NOW(),
        NOW()
    )
    ON CONFLICT (game_id, currency_code) DO UPDATE SET
        currency_type = COALESCE(p_currency_type, game.game_limits.currency_type),
        min_bet = p_min_bet,
        max_bet = p_max_bet,
        default_bet = COALESCE(p_default_bet, game.game_limits.default_bet),
        max_win = COALESCE(p_max_win, game.game_limits.max_win),
        is_active = true,
        updated_at = NOW();
END;
$$;

COMMENT ON FUNCTION game.game_limit_upsert IS 'Upserts per-game currency limit (client override). Supports fiat (type=1) and crypto (type=2). Auth-agnostic.';

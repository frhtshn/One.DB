-- ================================================================
-- GAME_LIMIT_LIST: Oyun limit listesi
-- ================================================================
-- Aktif limitleri döner (is_active=true varsayılan).
-- currency_type, currency_code sıralı.
-- Auth-agnostic.
-- ================================================================

DROP FUNCTION IF EXISTS game.game_limit_list(BIGINT);

CREATE OR REPLACE FUNCTION game.game_limit_list(
    p_game_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_game_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.id-required';
    END IF;

    IF NOT EXISTS(SELECT 1 FROM game.game_settings WHERE game_id = p_game_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.game.not-found';
    END IF;

    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'currencyCode', gl.currency_code,
            'currencyType', gl.currency_type,
            'minBet', gl.min_bet,
            'maxBet', gl.max_bet,
            'defaultBet', gl.default_bet,
            'maxWin', gl.max_win,
            'isActive', gl.is_active
        ) ORDER BY gl.currency_type, gl.currency_code
    ), '[]'::jsonb)
    INTO v_result
    FROM game.game_limits gl
    WHERE gl.game_id = p_game_id AND gl.is_active = true;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION game.game_limit_list(BIGINT) IS 'Returns active currency limits for a game. Ordered by currency_type then currency_code. Auth-agnostic.';

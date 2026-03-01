-- ================================================================
-- GAME_SETTINGS_REMOVE: Oyun devre dışı bırak (soft delete)
-- ================================================================
-- is_enabled=false yapar. Fiziksel DELETE yok.
-- game_limits kayıtları korunur.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS game.game_settings_remove(BIGINT);

CREATE OR REPLACE FUNCTION game.game_settings_remove(
    p_game_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_game_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.id-required';
    END IF;

    UPDATE game.game_settings
    SET is_enabled = false, updated_at = NOW()
    WHERE game_id = p_game_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.game.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION game.game_settings_remove(BIGINT) IS 'Soft-disables a game in client DB (is_enabled=false). No physical DELETE, game_limits preserved. Auth-agnostic.';

-- ================================================================
-- LOBBY_SECTION_GAME_REMOVE: Lobi bölümünden oyunu kaldır (soft delete)
-- ================================================================

DROP FUNCTION IF EXISTS game.remove_game_from_lobby_section(BIGINT, BIGINT, INTEGER);

CREATE OR REPLACE FUNCTION game.remove_game_from_lobby_section(
    p_lobby_section_id  BIGINT,
    p_game_id           BIGINT,
    p_user_id           INTEGER DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_lobby_section_id IS NULL THEN
        RAISE EXCEPTION 'error.lobby-section-game.section-id-required';
    END IF;
    IF p_game_id IS NULL THEN
        RAISE EXCEPTION 'error.lobby-section-game.game-id-required';
    END IF;

    UPDATE game.lobby_section_games
    SET
        is_active  = FALSE,
        updated_by = p_user_id,
        updated_at = NOW()
    WHERE lobby_section_id = p_lobby_section_id
      AND game_id = p_game_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'error.lobby-section-game.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION game.remove_game_from_lobby_section(BIGINT, BIGINT, INTEGER) IS 'Soft-remove a game from a lobby section by setting is_active = FALSE.';

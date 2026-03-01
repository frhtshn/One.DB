-- ================================================================
-- LOBBY_SECTION_GAME_LIST: Lobi bölümündeki oyunları listele
-- Backend game_id'lere göre game catalog'dan bilgi zenginleştirir
-- ================================================================

DROP FUNCTION IF EXISTS game.list_lobby_section_games(BIGINT, BOOLEAN);

CREATE OR REPLACE FUNCTION game.list_lobby_section_games(
    p_lobby_section_id  BIGINT,
    p_include_inactive  BOOLEAN DEFAULT FALSE
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_lobby_section_id IS NULL THEN
        RAISE EXCEPTION 'error.lobby-section-game.section-id-required';
    END IF;

    RETURN (
        SELECT COALESCE(jsonb_agg(jsonb_build_object(
            'id',           id,
            'gameId',       game_id,
            'displayOrder', display_order,
            'isActive',     is_active,
            'createdAt',    created_at
        ) ORDER BY display_order, id), '[]'::JSONB)
        FROM game.lobby_section_games
        WHERE lobby_section_id = p_lobby_section_id
          AND (p_include_inactive OR is_active = TRUE)
    );
END;
$$;

COMMENT ON FUNCTION game.list_lobby_section_games(BIGINT, BOOLEAN) IS 'List game assignments for a lobby section. Returns game_id values ordered by display_order; backend must enrich with game details from core DB.';

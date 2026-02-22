-- ================================================================
-- LOBBY_SECTION_GAME_ADD: Lobi bölümüne oyun ekle
-- Sadece section_type = 'manual' olan bölümler için
-- game_id backend'de core DB'ye karşı doğrulanmalıdır
-- ================================================================

DROP FUNCTION IF EXISTS game.add_game_to_lobby_section(BIGINT, BIGINT, SMALLINT, INTEGER);

CREATE OR REPLACE FUNCTION game.add_game_to_lobby_section(
    p_lobby_section_id  BIGINT,
    p_game_id           BIGINT,
    p_display_order     SMALLINT    DEFAULT 0,
    p_user_id           INTEGER     DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id            BIGINT;
    v_section_type  VARCHAR(30);
BEGIN
    IF p_lobby_section_id IS NULL THEN
        RAISE EXCEPTION 'error.lobby-section-game.section-id-required';
    END IF;
    IF p_game_id IS NULL THEN
        RAISE EXCEPTION 'error.lobby-section-game.game-id-required';
    END IF;

    -- Bölüm türü kontrolü
    SELECT section_type INTO v_section_type
    FROM game.lobby_sections
    WHERE id = p_lobby_section_id AND is_active = TRUE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'error.lobby-section-game.section-not-found';
    END IF;
    IF v_section_type <> 'manual' THEN
        RAISE EXCEPTION 'error.lobby-section-game.section-not-manual';
    END IF;

    INSERT INTO game.lobby_section_games (
        lobby_section_id, game_id, display_order, created_by, updated_by
    )
    VALUES (
        p_lobby_section_id, p_game_id, COALESCE(p_display_order, 0), p_user_id, p_user_id
    )
    ON CONFLICT ON CONSTRAINT uq_lobby_section_game DO UPDATE SET
        display_order = EXCLUDED.display_order,
        is_active     = TRUE,
        updated_by    = EXCLUDED.updated_by,
        updated_at    = NOW()
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION game.add_game_to_lobby_section(BIGINT, BIGINT, SMALLINT, INTEGER) IS 'Add a game to a manual lobby section. game_id must be validated by backend against core DB. Reactivates if previously removed. Returns the assignment ID.';

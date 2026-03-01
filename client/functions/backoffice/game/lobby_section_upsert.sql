-- ================================================================
-- LOBBY_SECTION_UPSERT: Lobi bölümü ekle / güncelle
-- code alanı üzerinden UPSERT yapılır
-- ================================================================

DROP FUNCTION IF EXISTS game.upsert_lobby_section(VARCHAR, VARCHAR, SMALLINT, SMALLINT, VARCHAR, INTEGER);

CREATE OR REPLACE FUNCTION game.upsert_lobby_section(
    p_code          VARCHAR(100),
    p_section_type  VARCHAR(30)     DEFAULT 'manual',
    p_max_items     SMALLINT        DEFAULT 20,
    p_display_order SMALLINT        DEFAULT 0,
    p_link_url      VARCHAR(500)    DEFAULT NULL,
    p_user_id       INTEGER         DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    IF p_code IS NULL OR TRIM(p_code) = '' THEN
        RAISE EXCEPTION 'error.lobby-section.code-required';
    END IF;
    IF p_max_items IS NOT NULL AND p_max_items < 1 THEN
        RAISE EXCEPTION 'error.lobby-section.max-items-invalid';
    END IF;

    INSERT INTO game.lobby_sections (
        code, section_type, max_items, display_order, link_url, created_by, updated_by
    )
    VALUES (
        TRIM(p_code), COALESCE(p_section_type, 'manual'),
        COALESCE(p_max_items, 20), COALESCE(p_display_order, 0),
        p_link_url, p_user_id, p_user_id
    )
    ON CONFLICT (code) DO UPDATE SET
        section_type  = EXCLUDED.section_type,
        max_items     = EXCLUDED.max_items,
        display_order = EXCLUDED.display_order,
        link_url      = EXCLUDED.link_url,
        is_active     = TRUE,
        updated_by    = EXCLUDED.updated_by,
        updated_at    = NOW()
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION game.upsert_lobby_section(VARCHAR, VARCHAR, SMALLINT, SMALLINT, VARCHAR, INTEGER) IS 'Insert or update a lobby section by code. section_type: manual | auto_new | auto_popular | auto_jackpot | auto_top_rated. Returns the section ID.';

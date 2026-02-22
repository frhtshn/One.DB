-- ================================================================
-- LOBBY_SECTION_LIST: Lobi bölümlerini listele
-- Çevirilerle birlikte döner (BO paneli)
-- ================================================================

DROP FUNCTION IF EXISTS game.list_lobby_sections(BOOLEAN);

CREATE OR REPLACE FUNCTION game.list_lobby_sections(
    p_include_inactive BOOLEAN DEFAULT FALSE
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (
        SELECT COALESCE(jsonb_agg(jsonb_build_object(
            'id',           s.id,
            'code',         s.code,
            'sectionType',  s.section_type,
            'maxItems',     s.max_items,
            'displayOrder', s.display_order,
            'linkUrl',      s.link_url,
            'isActive',     s.is_active,
            'createdAt',    s.created_at,
            'updatedAt',    s.updated_at,
            'translations', COALESCE((
                SELECT jsonb_agg(jsonb_build_object(
                    'languageCode', t.language_code,
                    'title',        t.title,
                    'subtitle',     t.subtitle
                ))
                FROM game.lobby_section_translations t
                WHERE t.lobby_section_id = s.id
            ), '[]'::JSONB)
        ) ORDER BY s.display_order, s.id), '[]'::JSONB)
        FROM game.lobby_sections s
        WHERE (p_include_inactive OR s.is_active = TRUE)
    );
END;
$$;

COMMENT ON FUNCTION game.list_lobby_sections(BOOLEAN) IS 'List lobby sections with translations. Returns JSONB array ordered by display_order.';

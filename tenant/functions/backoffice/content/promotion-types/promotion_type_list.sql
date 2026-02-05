-- ================================================================
-- PROMOTION_TYPE_LIST: Promosyon türü listesi (Backoffice)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır
-- Dropdown ve liste görünümü için kullanılır
-- ================================================================

DROP FUNCTION IF EXISTS content.promotion_type_list(BOOLEAN, CHAR(2));

CREATE OR REPLACE FUNCTION content.promotion_type_list(
    p_is_active BOOLEAN DEFAULT NULL,
    p_language CHAR(2) DEFAULT 'en'
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    RETURN COALESCE((
        SELECT jsonb_agg(
            jsonb_build_object(
                'id', pt.id,
                'code', pt.code,
                'icon', pt.icon,
                'color', pt.color,
                'badgeText', pt.badge_text,
                'sortOrder', pt.sort_order,
                'isActive', pt.is_active,
                -- Çeviri
                'name', COALESCE(t.name, t_def.name, pt.code),
                'description', COALESCE(t.description, t_def.description)
            ) ORDER BY pt.sort_order, pt.code
        )
        FROM content.promotion_types pt
        LEFT JOIN content.promotion_type_translations t
            ON t.promotion_type_id = pt.id AND t.language_code = p_language
        LEFT JOIN content.promotion_type_translations t_def
            ON t_def.promotion_type_id = pt.id AND t_def.language_code = 'en'
        WHERE (p_is_active IS NULL OR pt.is_active = p_is_active)
    ), '[]'::jsonb);
END;
$$;

COMMENT ON FUNCTION content.promotion_type_list IS 'Lists promotion types for backoffice dropdown/list. Auth check done in Core DB.';

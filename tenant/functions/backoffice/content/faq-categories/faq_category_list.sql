-- ================================================================
-- FAQ_CATEGORY_LIST: SSS kategori listesi (Backoffice)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır
-- Dropdown ve liste görünümü için kullanılır
-- ================================================================

DROP FUNCTION IF EXISTS content.faq_category_list(BOOLEAN, CHAR(2));

CREATE OR REPLACE FUNCTION content.faq_category_list(
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
                'id', c.id,
                'code', c.code,
                'icon', c.icon,
                'sortOrder', c.sort_order,
                'isActive', c.is_active,
                'createdAt', c.created_at,
                -- Çeviri
                'name', COALESCE(t.name, t_en.name, c.code),
                'description', COALESCE(t.description, t_en.description),
                -- Item sayısı
                'itemCount', (
                    SELECT COUNT(*) FROM content.faq_items i
                    WHERE i.category_id = c.id AND i.is_active = TRUE
                )
            ) ORDER BY c.sort_order, c.code
        )
        FROM content.faq_categories c
        LEFT JOIN content.faq_category_translations t
            ON t.category_id = c.id AND t.language_code = p_language
        LEFT JOIN content.faq_category_translations t_en
            ON t_en.category_id = c.id AND t_en.language_code = 'en'
        WHERE (p_is_active IS NULL OR c.is_active = p_is_active)
    ), '[]'::jsonb);
END;
$$;

COMMENT ON FUNCTION content.faq_category_list IS 'Lists FAQ categories for backoffice. Auth check done in Core DB.';

-- ================================================================
-- FAQ_CATEGORY_LIST: FAQ kategorileri listele
-- Dil parametreli çeviri desteği
-- ================================================================

DROP FUNCTION IF EXISTS content.faq_category_list(CHAR);

CREATE OR REPLACE FUNCTION content.faq_category_list(
    p_language_code     CHAR(2) DEFAULT 'en'
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', c.id,
        'code', c.code,
        'icon', c.icon,
        'sortOrder', c.sort_order,
        'name', t.name,
        'description', t.description,
        'itemCount', COALESCE(ic.cnt, 0)
    ) ORDER BY c.sort_order, c.id), '[]'::JSONB)
    INTO v_result
    FROM content.faq_categories c
    LEFT JOIN content.faq_category_translations t
        ON t.category_id = c.id AND t.language_code = p_language_code
    LEFT JOIN (
        SELECT category_id, COUNT(*) AS cnt
        FROM content.faq_items
        WHERE is_active = TRUE
        GROUP BY category_id
    ) ic ON ic.category_id = c.id
    WHERE c.is_active = TRUE;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION content.faq_category_list(CHAR) IS 'List active FAQ categories with translations and item counts.';

-- ================================================================
-- SLIDE_CATEGORY_LIST: Slide kategorileri listesi
-- ================================================================

DROP FUNCTION IF EXISTS content.slide_category_list(CHAR);

CREATE OR REPLACE FUNCTION content.slide_category_list(
    p_language_code     CHAR(2) DEFAULT 'en'
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', c.id, 'code', c.code, 'icon', c.icon, 'color', c.color,
        'sortOrder', c.sort_order, 'name', t.name, 'description', t.description
    ) ORDER BY c.sort_order, c.id), '[]'::JSONB)
    INTO v_result
    FROM content.slide_categories c
    LEFT JOIN content.slide_category_translations t
        ON t.category_id = c.id AND t.language_code = p_language_code
    WHERE c.is_active = TRUE;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION content.slide_category_list(CHAR) IS 'List active slide categories with translations.';

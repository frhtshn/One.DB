-- ================================================================
-- CONTENT_CATEGORY_LIST: İçerik kategorileri listele
-- Dil parametreli çeviri desteği
-- ================================================================

DROP FUNCTION IF EXISTS content.content_category_list(CHAR);

CREATE OR REPLACE FUNCTION content.content_category_list(
    p_language_code     CHAR(2) DEFAULT 'en'    -- Dil kodu
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
        'isActive', c.is_active,
        'name', t.name,
        'description', t.description
    ) ORDER BY c.sort_order, c.id), '[]'::JSONB)
    INTO v_result
    FROM content.content_categories c
    LEFT JOIN content.content_category_translations t
        ON t.category_id = c.id AND t.language_code = p_language_code
    WHERE c.is_active = TRUE;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION content.content_category_list(CHAR) IS 'List active content categories with translations for the specified language.';

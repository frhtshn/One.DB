-- ================================================================
-- CONTENT_TYPE_LIST: İçerik tipleri listele
-- Kategori filtreli, dil parametreli
-- ================================================================

DROP FUNCTION IF EXISTS content.content_type_list(INTEGER, CHAR);

CREATE OR REPLACE FUNCTION content.content_type_list(
    p_category_id       INTEGER DEFAULT NULL,   -- Kategori filtresi (NULL = tümü)
    p_language_code     CHAR(2) DEFAULT 'en'    -- Dil kodu
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', ct.id,
        'categoryId', ct.category_id,
        'code', ct.code,
        'templateKey', ct.template_key,
        'icon', ct.icon,
        'requiresAcceptance', ct.requires_acceptance,
        'showInFooter', ct.show_in_footer,
        'showInMenu', ct.show_in_menu,
        'sortOrder', ct.sort_order,
        'isActive', ct.is_active,
        'name', t.name,
        'description', t.description
    ) ORDER BY ct.sort_order, ct.id), '[]'::JSONB)
    INTO v_result
    FROM content.content_types ct
    LEFT JOIN content.content_type_translations t
        ON t.content_type_id = ct.id AND t.language_code = p_language_code
    WHERE ct.is_active = TRUE
      AND (p_category_id IS NULL OR ct.category_id = p_category_id);

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION content.content_type_list(INTEGER, CHAR) IS 'List active content types with translations. Optionally filter by category.';

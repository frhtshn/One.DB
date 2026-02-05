-- ================================================================
-- FAQ_CATEGORY_GET: Tek SSS kategorisi detayı (Backoffice)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır
-- Translations dahil döner
-- ================================================================

DROP FUNCTION IF EXISTS content.faq_category_get(INTEGER);

CREATE OR REPLACE FUNCTION content.faq_category_get(
    p_id INTEGER
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'id', c.id,
        'code', c.code,
        'icon', c.icon,
        'sortOrder', c.sort_order,
        'isActive', c.is_active,
        'createdAt', c.created_at,
        'createdBy', c.created_by,
        'updatedAt', c.updated_at,
        'updatedBy', c.updated_by,
        -- Translations
        'translations', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'id', t.id,
                'languageCode', t.language_code,
                'name', t.name,
                'description', t.description
            ) ORDER BY t.language_code)
            FROM content.faq_category_translations t
            WHERE t.category_id = c.id
        ), '[]'::jsonb)
    )
    INTO v_result
    FROM content.faq_categories c
    WHERE c.id = p_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.faq-category.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION content.faq_category_get IS 'Returns single FAQ category with translations. Auth check done in Core DB.';

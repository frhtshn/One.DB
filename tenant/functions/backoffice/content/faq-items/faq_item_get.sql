-- ================================================================
-- FAQ_ITEM_GET: Tek SSS maddesi detayı (Backoffice)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır
-- Translations dahil döner
-- ================================================================

DROP FUNCTION IF EXISTS content.faq_item_get(INTEGER);

CREATE OR REPLACE FUNCTION content.faq_item_get(
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
        'id', i.id,
        'categoryId', i.category_id,
        'categoryCode', c.code,
        'categoryName', COALESCE(ct.name, c.code),
        'sortOrder', i.sort_order,
        'viewCount', i.view_count,
        'helpfulCount', i.helpful_count,
        'notHelpfulCount', i.not_helpful_count,
        'isFeatured', i.is_featured,
        'isActive', i.is_active,
        'createdAt', i.created_at,
        'createdBy', i.created_by,
        'updatedAt', i.updated_at,
        'updatedBy', i.updated_by,
        -- Translations
        'translations', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'id', t.id,
                'languageCode', t.language_code,
                'question', t.question,
                'answer', t.answer,
                'status', t.status
            ) ORDER BY t.language_code)
            FROM content.faq_item_translations t
            WHERE t.faq_item_id = i.id
        ), '[]'::jsonb)
    )
    INTO v_result
    FROM content.faq_items i
    LEFT JOIN content.faq_categories c ON c.id = i.category_id
    LEFT JOIN content.faq_category_translations ct ON ct.category_id = c.id AND ct.language_code = 'en'
    WHERE i.id = p_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.faq-item.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION content.faq_item_get IS 'Returns single FAQ item with translations. Auth check done in Core DB.';

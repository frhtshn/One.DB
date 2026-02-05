-- ================================================================
-- FAQ_ITEM_LIST: SSS madde listesi (Backoffice)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır
-- Pagination ve filtreleme destekler
-- ================================================================

DROP FUNCTION IF EXISTS content.faq_item_list(INTEGER, INTEGER, INTEGER, BOOLEAN, BOOLEAN, TEXT, CHAR(2));

CREATE OR REPLACE FUNCTION content.faq_item_list(
    p_page INTEGER DEFAULT 1,
    p_page_size INTEGER DEFAULT 20,
    p_category_id INTEGER DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL,
    p_is_featured BOOLEAN DEFAULT NULL,
    p_search TEXT DEFAULT NULL,
    p_language CHAR(2) DEFAULT 'en'
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_offset INTEGER;
    v_total_count INTEGER;
    v_items JSONB;
BEGIN
    v_offset := (p_page - 1) * p_page_size;

    -- Total count
    SELECT COUNT(*) INTO v_total_count
    FROM content.faq_items i
    LEFT JOIN content.faq_item_translations t ON t.faq_item_id = i.id AND t.language_code = p_language
    WHERE (p_category_id IS NULL OR i.category_id = p_category_id)
      AND (p_is_active IS NULL OR i.is_active = p_is_active)
      AND (p_is_featured IS NULL OR i.is_featured = p_is_featured)
      AND (p_search IS NULL OR t.question ILIKE '%' || p_search || '%' OR t.answer ILIKE '%' || p_search || '%');

    -- Items
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', i.id,
            'categoryId', i.category_id,
            'categoryCode', c.code,
            'categoryName', COALESCE(ct.name, ct_en.name, c.code),
            'sortOrder', i.sort_order,
            'viewCount', i.view_count,
            'helpfulCount', i.helpful_count,
            'notHelpfulCount', i.not_helpful_count,
            'isFeatured', i.is_featured,
            'isActive', i.is_active,
            'createdAt', i.created_at,
            'updatedAt', i.updated_at,
            -- Çeviri
            'question', COALESCE(t.question, t_en.question),
            'answer', COALESCE(t.answer, t_en.answer)
        ) ORDER BY i.sort_order, i.id
    ), '[]'::jsonb)
    INTO v_items
    FROM (
        SELECT fi.* FROM content.faq_items fi
        LEFT JOIN content.faq_item_translations fit ON fit.faq_item_id = fi.id AND fit.language_code = p_language
        WHERE (p_category_id IS NULL OR fi.category_id = p_category_id)
          AND (p_is_active IS NULL OR fi.is_active = p_is_active)
          AND (p_is_featured IS NULL OR fi.is_featured = p_is_featured)
          AND (p_search IS NULL OR fit.question ILIKE '%' || p_search || '%' OR fit.answer ILIKE '%' || p_search || '%')
        ORDER BY fi.sort_order, fi.id
        LIMIT p_page_size OFFSET v_offset
    ) i
    LEFT JOIN content.faq_categories c ON c.id = i.category_id
    LEFT JOIN content.faq_category_translations ct ON ct.category_id = c.id AND ct.language_code = p_language
    LEFT JOIN content.faq_category_translations ct_en ON ct_en.category_id = c.id AND ct_en.language_code = 'en'
    LEFT JOIN content.faq_item_translations t ON t.faq_item_id = i.id AND t.language_code = p_language
    LEFT JOIN content.faq_item_translations t_en ON t_en.faq_item_id = i.id AND t_en.language_code = 'en';

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total_count,
        'page', p_page,
        'pageSize', p_page_size
    );
END;
$$;

COMMENT ON FUNCTION content.faq_item_list IS 'Lists FAQ items for backoffice with pagination and search. Auth check done in Core DB.';

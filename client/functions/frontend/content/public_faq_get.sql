-- ================================================================
-- PUBLIC_FAQ_GET: Tek SSS detay
-- view_count artırır (görüntülenme sayacı)
-- ================================================================

DROP FUNCTION IF EXISTS content.public_faq_get(INTEGER, CHAR);

CREATE OR REPLACE FUNCTION content.public_faq_get(
    p_id                INTEGER,            -- FAQ item ID
    p_language_code     CHAR(2) DEFAULT 'en' -- Dil kodu
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    -- Görüntülenme sayacını artır
    UPDATE content.faq_items
    SET view_count = view_count + 1
    WHERE id = p_id AND is_active = TRUE;

    -- Detay getir
    SELECT jsonb_build_object(
        'id', fi.id,
        'question', t.question,
        'answer', t.answer,
        'categoryCode', fc.code,
        'categoryName', fct.name,
        'isFeatured', fi.is_featured,
        'viewCount', fi.view_count,
        'helpfulCount', fi.helpful_count,
        'notHelpfulCount', fi.not_helpful_count
    ) INTO v_result
    FROM content.faq_items fi
    LEFT JOIN content.faq_categories fc ON fc.id = fi.category_id
    LEFT JOIN content.faq_category_translations fct
        ON fct.category_id = fc.id AND fct.language_code = p_language_code
    LEFT JOIN content.faq_item_translations t
        ON t.faq_item_id = fi.id AND t.language_code = p_language_code
    WHERE fi.id = p_id
      AND fi.is_active = TRUE
      AND t.status = 'published';

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION content.public_faq_get(INTEGER, CHAR) IS 'Get single FAQ item detail for frontend. Increments view_count on each call.';

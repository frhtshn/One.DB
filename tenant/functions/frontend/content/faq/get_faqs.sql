-- ================================================================
-- GET_FAQS: Aktif SSS'leri getir (Frontend)
-- ================================================================
-- Public content - yetki kontrolü gerekmez.
-- Kategorilerle birlikte gruplu döner.
-- ================================================================

DROP FUNCTION IF EXISTS content.get_faqs(CHAR(2), VARCHAR, BOOLEAN);

CREATE OR REPLACE FUNCTION content.get_faqs(
    p_language CHAR(2) DEFAULT 'en',
    p_category_code VARCHAR(50) DEFAULT NULL,  -- Belirli kategori (NULL = tümü)
    p_featured_only BOOLEAN DEFAULT FALSE       -- Sadece öne çıkanlar
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
                'name', COALESCE(ct.name, ct_en.name, c.code),
                'description', COALESCE(ct.description, ct_en.description),
                'items', COALESCE((
                    SELECT jsonb_agg(
                        jsonb_build_object(
                            'id', i.id,
                            'question', COALESCE(it.question, it_en.question),
                            'answer', COALESCE(it.answer, it_en.answer),
                            'isFeatured', i.is_featured,
                            'helpfulCount', i.helpful_count,
                            'notHelpfulCount', i.not_helpful_count
                        ) ORDER BY i.sort_order, i.id
                    )
                    FROM content.faq_items i
                    LEFT JOIN content.faq_item_translations it
                        ON it.faq_item_id = i.id AND it.language_code = p_language
                    LEFT JOIN content.faq_item_translations it_en
                        ON it_en.faq_item_id = i.id AND it_en.language_code = 'en'
                    WHERE i.category_id = c.id
                      AND i.is_active = TRUE
                      AND (p_featured_only = FALSE OR i.is_featured = TRUE)
                      -- En az bir çeviri olmalı
                      AND (it.id IS NOT NULL OR it_en.id IS NOT NULL)
                ), '[]'::jsonb)
            ) ORDER BY c.sort_order, c.code
        )
        FROM content.faq_categories c
        LEFT JOIN content.faq_category_translations ct
            ON ct.category_id = c.id AND ct.language_code = p_language
        LEFT JOIN content.faq_category_translations ct_en
            ON ct_en.category_id = c.id AND ct_en.language_code = 'en'
        WHERE c.is_active = TRUE
          AND (p_category_code IS NULL OR c.code = p_category_code)
          -- En az bir item olmalı
          AND EXISTS (
              SELECT 1 FROM content.faq_items i
              WHERE i.category_id = c.id AND i.is_active = TRUE
          )
    ), '[]'::jsonb);
END;
$$;

COMMENT ON FUNCTION content.get_faqs IS
'Returns active FAQs grouped by category for frontend.
No auth required (public content).
Filters: language, category_code, featured_only.
Usage: SELECT content.get_faqs(''tr'', ''payments'', FALSE)';

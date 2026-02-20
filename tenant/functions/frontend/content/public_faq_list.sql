-- ================================================================
-- PUBLIC_FAQ_LIST: Kategori bazlı yayınlanmış SSS listesi
-- Öne çıkan filtresi ve arama desteği
-- Sayfalanmış sonuç
-- ================================================================

DROP FUNCTION IF EXISTS content.public_faq_list(VARCHAR, CHAR, BOOLEAN, TEXT, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION content.public_faq_list(
    p_category_code     VARCHAR(50) DEFAULT NULL,   -- Kategori filtresi (NULL = tümü)
    p_language_code     CHAR(2)     DEFAULT 'en',    -- Dil kodu
    p_is_featured       BOOLEAN     DEFAULT NULL,    -- Öne çıkan filtresi
    p_search            TEXT        DEFAULT NULL,    -- Soru/cevap arama
    p_offset            INTEGER     DEFAULT 0,       -- Sayfalama: başlangıç
    p_limit             INTEGER     DEFAULT 20       -- Sayfalama: boyut
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_count INTEGER;
    v_items JSONB;
BEGIN
    -- Toplam sayı
    SELECT COUNT(*) INTO v_total_count
    FROM content.faq_items fi
    LEFT JOIN content.faq_categories fc ON fc.id = fi.category_id
    LEFT JOIN content.faq_item_translations t
        ON t.faq_item_id = fi.id AND t.language_code = p_language_code
    WHERE fi.is_active = TRUE
      AND t.status = 'published'
      AND (p_category_code IS NULL OR fc.code = p_category_code)
      AND (p_is_featured IS NULL OR fi.is_featured = p_is_featured)
      AND (p_search IS NULL OR t.question ILIKE '%' || p_search || '%'
           OR t.answer ILIKE '%' || p_search || '%');

    -- Sayfalanmış liste
    SELECT COALESCE(jsonb_agg(row_data ORDER BY sort_order), '[]'::JSONB)
    INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'id', fi.id,
            'question', t.question,
            'answer', t.answer,
            'categoryCode', fc.code,
            'isFeatured', fi.is_featured,
            'viewCount', fi.view_count,
            'helpfulCount', fi.helpful_count,
            'notHelpfulCount', fi.not_helpful_count
        ) AS row_data,
        fi.sort_order
        FROM content.faq_items fi
        LEFT JOIN content.faq_categories fc ON fc.id = fi.category_id
        LEFT JOIN content.faq_item_translations t
            ON t.faq_item_id = fi.id AND t.language_code = p_language_code
        WHERE fi.is_active = TRUE
          AND t.status = 'published'
          AND (p_category_code IS NULL OR fc.code = p_category_code)
          AND (p_is_featured IS NULL OR fi.is_featured = p_is_featured)
          AND (p_search IS NULL OR t.question ILIKE '%' || p_search || '%'
               OR t.answer ILIKE '%' || p_search || '%')
        ORDER BY fi.sort_order
        OFFSET p_offset
        LIMIT p_limit
    ) sub;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total_count
    );
END;
$$;

COMMENT ON FUNCTION content.public_faq_list(VARCHAR, CHAR, BOOLEAN, TEXT, INTEGER, INTEGER) IS 'List published FAQ items by category for frontend. Supports featured filter and text search.';

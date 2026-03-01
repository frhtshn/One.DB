-- ================================================================
-- PUBLIC_CONTENT_LIST: Tip kodu ile yayınlanmış içerik listesi
-- Sadece published + active + süresi dolmamış
-- FE sayfalı listeleme
-- ================================================================

DROP FUNCTION IF EXISTS content.public_content_list(VARCHAR, CHAR, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION content.public_content_list(
    p_type_code         VARCHAR(50),        -- İçerik tipi kodu
    p_language_code     CHAR(2),            -- Dil kodu
    p_offset            INTEGER DEFAULT 0,  -- Sayfalama: başlangıç
    p_limit             INTEGER DEFAULT 20  -- Sayfalama: boyut
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
    FROM content.contents c
    INNER JOIN content.content_types ct ON ct.id = c.content_type_id
    WHERE ct.code = p_type_code
      AND c.status = 'published'
      AND c.is_active = TRUE
      AND (c.expires_at IS NULL OR c.expires_at > NOW());

    -- Sayfalanmış liste
    SELECT COALESCE(jsonb_agg(row_data ORDER BY published_at DESC), '[]'::JSONB)
    INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'slug', c.slug,
            'title', t.title,
            'subtitle', t.subtitle,
            'summary', t.summary,
            'featuredImageUrl', c.featured_image_url,
            'publishedAt', c.published_at
        ) AS row_data,
        c.published_at
        FROM content.contents c
        INNER JOIN content.content_types ct ON ct.id = c.content_type_id
        LEFT JOIN content.content_translations t
            ON t.content_id = c.id AND t.language_code = p_language_code
        WHERE ct.code = p_type_code
          AND c.status = 'published'
          AND c.is_active = TRUE
          AND (c.expires_at IS NULL OR c.expires_at > NOW())
        ORDER BY c.published_at DESC
        OFFSET p_offset
        LIMIT p_limit
    ) sub;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total_count
    );
END;
$$;

COMMENT ON FUNCTION content.public_content_list(VARCHAR, CHAR, INTEGER, INTEGER) IS 'List published contents by type code for frontend. Only active, published, non-expired items.';

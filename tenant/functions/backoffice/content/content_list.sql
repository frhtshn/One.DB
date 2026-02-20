-- ================================================================
-- CONTENT_LIST: İçerik listesi
-- Tip, durum, arama, sayfalı filtreleme
-- ================================================================

DROP FUNCTION IF EXISTS content.content_list(INTEGER, VARCHAR, TEXT, CHAR, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION content.content_list(
    p_content_type_id   INTEGER     DEFAULT NULL,   -- Tip filtresi
    p_status            VARCHAR(20) DEFAULT NULL,    -- Durum filtresi: draft, published, archived
    p_search            TEXT        DEFAULT NULL,    -- Başlık/slug arama
    p_language_code     CHAR(2)     DEFAULT 'en',    -- Dil kodu
    p_offset            INTEGER     DEFAULT 0,       -- Sayfalama: başlangıç
    p_limit             INTEGER     DEFAULT 20       -- Sayfalama: sayfa boyutu
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
    LEFT JOIN content.content_translations t
        ON t.content_id = c.id AND t.language_code = p_language_code
    WHERE c.is_active = TRUE
      AND (p_content_type_id IS NULL OR c.content_type_id = p_content_type_id)
      AND (p_status IS NULL OR c.status = p_status)
      AND (p_search IS NULL OR c.slug ILIKE '%' || p_search || '%'
           OR t.title ILIKE '%' || p_search || '%');

    -- Sayfalanmış liste
    SELECT COALESCE(jsonb_agg(row_data ORDER BY created_at DESC), '[]'::JSONB)
    INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'id', c.id,
            'contentTypeId', c.content_type_id,
            'slug', c.slug,
            'featuredImageUrl', c.featured_image_url,
            'version', c.version,
            'status', c.status,
            'publishedAt', c.published_at,
            'title', t.title,
            'summary', t.summary,
            'createdAt', c.created_at,
            'updatedAt', c.updated_at
        ) AS row_data,
        c.created_at
        FROM content.contents c
        LEFT JOIN content.content_translations t
            ON t.content_id = c.id AND t.language_code = p_language_code
        WHERE c.is_active = TRUE
          AND (p_content_type_id IS NULL OR c.content_type_id = p_content_type_id)
          AND (p_status IS NULL OR c.status = p_status)
          AND (p_search IS NULL OR c.slug ILIKE '%' || p_search || '%'
               OR t.title ILIKE '%' || p_search || '%')
        ORDER BY c.created_at DESC
        OFFSET p_offset
        LIMIT p_limit
    ) sub;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total_count
    );
END;
$$;

COMMENT ON FUNCTION content.content_list(INTEGER, VARCHAR, TEXT, CHAR, INTEGER, INTEGER) IS 'List contents with type, status, and search filters. Paginated with total count.';

-- ================================================================
-- PUBLIC_CONTENT_GET: Slug ile yayınlanmış içerik getir
-- Sadece published + active + süresi dolmamış içerikler
-- FE için SEO metadata dahil
-- ================================================================

DROP FUNCTION IF EXISTS content.public_content_get(VARCHAR, CHAR);

CREATE OR REPLACE FUNCTION content.public_content_get(
    p_slug              VARCHAR(255),       -- URL slug
    p_language_code     CHAR(2)             -- Dil kodu
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'title', t.title,
        'subtitle', t.subtitle,
        'summary', t.summary,
        'body', t.body,
        'metaTitle', t.meta_title,
        'metaDescription', t.meta_description,
        'featuredImageUrl', c.featured_image_url,
        'publishedAt', c.published_at,
        'contentType', ct.code,
        'requiresAcceptance', ct.requires_acceptance,
        'attachments', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'fileName', a.file_name,
                'filePath', a.file_path,
                'fileType', a.file_type,
                'altText', a.alt_text,
                'caption', a.caption
            ) ORDER BY a.sort_order)
            FROM content.content_attachments a
            WHERE a.content_id = c.id
        ), '[]'::JSONB)
    ) INTO v_result
    FROM content.contents c
    INNER JOIN content.content_translations t
        ON t.content_id = c.id AND t.language_code = p_language_code
    INNER JOIN content.content_types ct
        ON ct.id = c.content_type_id
    WHERE c.slug = p_slug
      AND c.status = 'published'
      AND c.is_active = TRUE
      AND (c.expires_at IS NULL OR c.expires_at > NOW());

    -- İçerik bulunamadıysa NULL döner (404 — FE yönetir)
    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION content.public_content_get(VARCHAR, CHAR) IS 'Get published content by slug for frontend rendering. Returns NULL if not found or expired.';

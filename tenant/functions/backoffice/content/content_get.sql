-- ================================================================
-- CONTENT_GET: İçerik detay getir
-- Çeviriler, ekler ve versiyon geçmişi dahil
-- ================================================================

DROP FUNCTION IF EXISTS content.content_get(INTEGER);

CREATE OR REPLACE FUNCTION content.content_get(
    p_id                INTEGER             -- İçerik ID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    -- Parametre doğrulama
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'error.content.id-required';
    END IF;

    SELECT jsonb_build_object(
        'id', c.id,
        'contentTypeId', c.content_type_id,
        'slug', c.slug,
        'featuredImageUrl', c.featured_image_url,
        'version', c.version,
        'status', c.status,
        'publishedAt', c.published_at,
        'expiresAt', c.expires_at,
        'isActive', c.is_active,
        'createdAt', c.created_at,
        'createdBy', c.created_by,
        'updatedAt', c.updated_at,
        'updatedBy', c.updated_by,
        -- Çeviriler
        'translations', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'id', t.id,
                'languageCode', t.language_code,
                'title', t.title,
                'subtitle', t.subtitle,
                'summary', t.summary,
                'body', t.body,
                'metaTitle', t.meta_title,
                'metaDescription', t.meta_description,
                'metaKeywords', t.meta_keywords,
                'status', t.status
            ) ORDER BY t.language_code)
            FROM content.content_translations t
            WHERE t.content_id = c.id
        ), '[]'::JSONB),
        -- Ekler
        'attachments', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'id', a.id,
                'fileName', a.file_name,
                'filePath', a.file_path,
                'fileType', a.file_type,
                'fileSize', a.file_size,
                'altText', a.alt_text,
                'caption', a.caption,
                'sortOrder', a.sort_order,
                'isFeatured', a.is_featured
            ) ORDER BY a.sort_order)
            FROM content.content_attachments a
            WHERE a.content_id = c.id
        ), '[]'::JSONB),
        -- Versiyon geçmişi (son 10)
        'versions', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'id', v.id,
                'languageCode', v.language_code,
                'version', v.version,
                'title', v.title,
                'changeNote', v.change_note,
                'createdAt', v.created_at,
                'createdBy', v.created_by
            ) ORDER BY v.version DESC, v.language_code)
            FROM content.content_versions v
            WHERE v.content_id = c.id
        ), '[]'::JSONB)
    ) INTO v_result
    FROM content.contents c
    WHERE c.id = p_id AND c.is_active = TRUE;

    IF v_result IS NULL THEN
        RAISE EXCEPTION 'error.content.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION content.content_get(INTEGER) IS 'Get content detail with translations, attachments, and version history.';

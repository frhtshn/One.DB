-- ================================================================
-- CONTENT_CREATE: İçerik oluştur
-- Çeviriler ve ekler dahil
-- Başlangıç durumu: draft
-- ================================================================

DROP FUNCTION IF EXISTS content.content_create(INTEGER, VARCHAR, VARCHAR, JSONB, JSONB, INTEGER);

CREATE OR REPLACE FUNCTION content.content_create(
    p_content_type_id   INTEGER,                -- İçerik tipi
    p_slug              VARCHAR(255),            -- URL slug (unique)
    p_featured_image_url VARCHAR(500) DEFAULT NULL, -- Kapak görseli
    p_translations      JSONB,                   -- [{languageCode, title, subtitle, summary, body, metaTitle, metaDescription, metaKeywords}]
    p_attachments       JSONB        DEFAULT NULL, -- [{fileName, filePath, fileType, fileSize, altText, caption}]
    p_user_id           INTEGER                  -- İşlemi yapan kullanıcı
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_id INTEGER;
    v_item JSONB;
    v_idx INTEGER := 0;
BEGIN
    -- Parametre doğrulama
    IF p_content_type_id IS NULL THEN
        RAISE EXCEPTION 'error.content.type-id-required';
    END IF;

    IF p_slug IS NULL OR p_slug = '' THEN
        RAISE EXCEPTION 'error.content.slug-required';
    END IF;

    IF p_user_id IS NULL THEN
        RAISE EXCEPTION 'error.content.user-id-required';
    END IF;

    IF p_translations IS NULL OR jsonb_array_length(p_translations) = 0 THEN
        RAISE EXCEPTION 'error.content.translations-required';
    END IF;

    -- İçerik oluştur
    INSERT INTO content.contents (
        content_type_id, slug, featured_image_url,
        status, version, created_by, updated_by
    )
    VALUES (
        p_content_type_id, p_slug, p_featured_image_url,
        'draft', 1, p_user_id, p_user_id
    )
    RETURNING id INTO v_id;

    -- Çeviriler
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_translations)
    LOOP
        INSERT INTO content.content_translations (
            content_id, language_code,
            title, subtitle, summary, body,
            meta_title, meta_description, meta_keywords,
            status, created_by, updated_by
        )
        VALUES (
            v_id,
            v_item ->> 'languageCode',
            v_item ->> 'title',
            v_item ->> 'subtitle',
            v_item ->> 'summary',
            v_item ->> 'body',
            v_item ->> 'metaTitle',
            v_item ->> 'metaDescription',
            v_item ->> 'metaKeywords',
            'draft',
            p_user_id,
            p_user_id
        );
    END LOOP;

    -- Ekler (varsa)
    IF p_attachments IS NOT NULL AND jsonb_array_length(p_attachments) > 0 THEN
        FOR v_item IN SELECT * FROM jsonb_array_elements(p_attachments)
        LOOP
            INSERT INTO content.content_attachments (
                content_id, file_name, file_path, file_type, file_size,
                alt_text, caption, sort_order, created_by
            )
            VALUES (
                v_id,
                v_item ->> 'fileName',
                v_item ->> 'filePath',
                v_item ->> 'fileType',
                (v_item ->> 'fileSize')::INTEGER,
                v_item ->> 'altText',
                v_item ->> 'caption',
                v_idx,
                p_user_id
            );
            v_idx := v_idx + 1;
        END LOOP;
    END IF;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION content.content_create(INTEGER, VARCHAR, VARCHAR, JSONB, JSONB, INTEGER) IS 'Create new content with translations and attachments. Initial status is draft.';

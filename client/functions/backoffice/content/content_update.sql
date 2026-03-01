-- ================================================================
-- CONTENT_UPDATE: İçerik güncelle
-- Çeviriler ve ekler dahil (DELETE + INSERT semantiği)
-- ================================================================

DROP FUNCTION IF EXISTS content.content_update(INTEGER, INTEGER, VARCHAR, VARCHAR, TEXT, TEXT);

CREATE OR REPLACE FUNCTION content.content_update(
    p_id                 INTEGER,                  -- İçerik ID
    p_user_id            INTEGER,                   -- İşlemi yapan kullanıcı
    p_slug               VARCHAR(255) DEFAULT NULL, -- URL slug
    p_featured_image_url VARCHAR(500) DEFAULT NULL, -- Kapak görseli
    p_translations       TEXT         DEFAULT NULL, -- JSON: [{languageCode, title, subtitle, summary, body, metaTitle, metaDescription, metaKeywords}]
    p_attachments        TEXT         DEFAULT NULL  -- JSON: [{fileName, filePath, fileType, fileSize, altText, caption}]
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_item JSONB;
    v_idx INTEGER := 0;
    v_translations JSONB;
    v_attachments  JSONB;
BEGIN
    -- TEXT -> JSONB cast
    IF p_translations IS NOT NULL THEN
        v_translations := p_translations::jsonb;
    END IF;
    IF p_attachments IS NOT NULL THEN
        v_attachments := p_attachments::jsonb;
    END IF;

    -- Parametre doğrulama
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'error.content.id-required';
    END IF;

    IF p_user_id IS NULL THEN
        RAISE EXCEPTION 'error.content.user-id-required';
    END IF;

    -- Kayıt kontrolü
    IF NOT EXISTS (SELECT 1 FROM content.contents WHERE id = p_id AND is_active = TRUE) THEN
        RAISE EXCEPTION 'error.content.not-found';
    END IF;

    -- Ana kayıt güncelle
    UPDATE content.contents
    SET slug               = COALESCE(p_slug, slug),
        featured_image_url = COALESCE(p_featured_image_url, featured_image_url),
        updated_by         = p_user_id,
        updated_at         = NOW()
    WHERE id = p_id;

    -- Çeviriler (varsa DELETE + INSERT)
    IF v_translations IS NOT NULL AND jsonb_array_length(v_translations) > 0 THEN
        DELETE FROM content.content_translations WHERE content_id = p_id;

        FOR v_item IN SELECT * FROM jsonb_array_elements(v_translations)
        LOOP
            INSERT INTO content.content_translations (
                content_id, language_code,
                title, subtitle, summary, body,
                meta_title, meta_description, meta_keywords,
                status, created_by, updated_by
            )
            VALUES (
                p_id,
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
    END IF;

    -- Ekler (varsa DELETE + INSERT)
    IF v_attachments IS NOT NULL THEN
        DELETE FROM content.content_attachments WHERE content_id = p_id;

        IF jsonb_array_length(v_attachments) > 0 THEN
            FOR v_item IN SELECT * FROM jsonb_array_elements(v_attachments)
            LOOP
                INSERT INTO content.content_attachments (
                    content_id, file_name, file_path, file_type, file_size,
                    alt_text, caption, sort_order, created_by
                )
                VALUES (
                    p_id,
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
    END IF;
END;
$$;

COMMENT ON FUNCTION content.content_update(INTEGER, INTEGER, VARCHAR, VARCHAR, TEXT, TEXT) IS 'Update content with translations and attachments. Sub-records use delete+insert semantics.';

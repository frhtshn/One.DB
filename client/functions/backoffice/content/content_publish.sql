-- ================================================================
-- CONTENT_PUBLISH: İçeriği yayınla (draft → published)
-- Versiyon artırır ve snapshot oluşturur
-- Tüm diller için versiyon kaydı alır
-- ================================================================

DROP FUNCTION IF EXISTS content.content_publish(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION content.content_publish(
    p_id                INTEGER,            -- İçerik ID
    p_user_id           INTEGER             -- İşlemi yapan kullanıcı
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_version INTEGER;
BEGIN
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

    -- Versiyon artır ve yayınla
    UPDATE content.contents
    SET status       = 'published',
        published_at = NOW(),
        version      = version + 1,
        updated_by   = p_user_id,
        updated_at   = NOW()
    WHERE id = p_id
    RETURNING version INTO v_new_version;

    -- Her dil için versiyon snapshot'ı oluştur
    INSERT INTO content.content_versions (
        content_id, language_code, version,
        title, subtitle, summary, body,
        meta_title, meta_description, meta_keywords,
        created_by
    )
    SELECT
        t.content_id, t.language_code, v_new_version,
        t.title, t.subtitle, t.summary, t.body,
        t.meta_title, t.meta_description, t.meta_keywords,
        p_user_id
    FROM content.content_translations t
    WHERE t.content_id = p_id;

    -- Çevirilerin durumunu güncelle
    UPDATE content.content_translations
    SET status = 'published', updated_by = p_user_id, updated_at = NOW()
    WHERE content_id = p_id;
END;
$$;

COMMENT ON FUNCTION content.content_publish(INTEGER, INTEGER) IS 'Publish content: sets status to published, increments version, and creates version snapshots for all translations.';

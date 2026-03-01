-- ================================================================
-- CONTENT_TYPE_DELETE: İçerik tipi soft delete
-- Aktif content varsa hata verir
-- ================================================================

DROP FUNCTION IF EXISTS content.content_type_delete(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION content.content_type_delete(
    p_id                INTEGER,            -- İçerik tipi ID
    p_user_id           INTEGER             -- İşlemi yapan kullanıcı
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Parametre doğrulama
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'error.content.type-id-required';
    END IF;

    -- Kayıt kontrolü
    IF NOT EXISTS (SELECT 1 FROM content.content_types WHERE id = p_id AND is_active = TRUE) THEN
        RAISE EXCEPTION 'error.content.type-not-found';
    END IF;

    -- Bağımlılık kontrolü: aktif content var mı?
    IF EXISTS (SELECT 1 FROM content.contents WHERE content_type_id = p_id AND is_active = TRUE) THEN
        RAISE EXCEPTION 'error.content.type-has-active-contents';
    END IF;

    -- Soft delete
    UPDATE content.content_types
    SET is_active = FALSE, updated_by = p_user_id, updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION content.content_type_delete(INTEGER, INTEGER) IS 'Soft delete content type. Fails if active contents exist under this type.';

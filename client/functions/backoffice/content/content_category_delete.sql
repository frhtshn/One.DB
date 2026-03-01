-- ================================================================
-- CONTENT_CATEGORY_DELETE: İçerik kategorisi soft delete
-- Aktif content_type varsa hata verir
-- ================================================================

DROP FUNCTION IF EXISTS content.content_category_delete(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION content.content_category_delete(
    p_id                INTEGER,            -- Kategori ID
    p_user_id           INTEGER             -- İşlemi yapan kullanıcı
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Parametre doğrulama
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'error.content.category-id-required';
    END IF;

    -- Kayıt kontrolü
    IF NOT EXISTS (SELECT 1 FROM content.content_categories WHERE id = p_id AND is_active = TRUE) THEN
        RAISE EXCEPTION 'error.content.category-not-found';
    END IF;

    -- Bağımlılık kontrolü: aktif content_type var mı?
    IF EXISTS (SELECT 1 FROM content.content_types WHERE category_id = p_id AND is_active = TRUE) THEN
        RAISE EXCEPTION 'error.content.category-has-active-types';
    END IF;

    -- Soft delete
    UPDATE content.content_categories
    SET is_active = FALSE, updated_by = p_user_id, updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION content.content_category_delete(INTEGER, INTEGER) IS 'Soft delete content category. Fails if active content types exist under this category.';

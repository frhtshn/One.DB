-- ================================================================
-- FAQ_CATEGORY_DELETE: FAQ kategorisi soft delete
-- Aktif item varsa hata verir
-- ================================================================

DROP FUNCTION IF EXISTS content.faq_category_delete(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION content.faq_category_delete(
    p_id                INTEGER,            -- Kategori ID
    p_user_id           INTEGER             -- İşlemi yapan kullanıcı
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'error.faq.category-id-required';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM content.faq_categories WHERE id = p_id AND is_active = TRUE) THEN
        RAISE EXCEPTION 'error.faq.category-not-found';
    END IF;

    IF EXISTS (SELECT 1 FROM content.faq_items WHERE category_id = p_id AND is_active = TRUE) THEN
        RAISE EXCEPTION 'error.faq.category-has-active-items';
    END IF;

    UPDATE content.faq_categories
    SET is_active = FALSE, updated_by = p_user_id, updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION content.faq_category_delete(INTEGER, INTEGER) IS 'Soft delete FAQ category. Fails if active FAQ items exist under this category.';

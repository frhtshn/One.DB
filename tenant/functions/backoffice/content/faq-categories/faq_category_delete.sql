-- ================================================================
-- FAQ_CATEGORY_DELETE: SSS kategorisi sil (Backoffice)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır
-- İçinde item olan kategori silinemez
-- ================================================================

DROP FUNCTION IF EXISTS content.faq_category_delete(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION content.faq_category_delete(
    p_id INTEGER,
    p_operator_id INTEGER DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM content.faq_categories WHERE id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.faq-category.not-found';
    END IF;

    -- Kullanım kontrolü
    IF EXISTS(SELECT 1 FROM content.faq_items WHERE category_id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.faq-category.has-items';
    END IF;

    -- İlişkili translations sil
    DELETE FROM content.faq_category_translations WHERE category_id = p_id;

    -- Kategoriyi sil
    DELETE FROM content.faq_categories WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION content.faq_category_delete IS 'Deletes a FAQ category. Cannot delete if has items. Auth check done in Core DB.';

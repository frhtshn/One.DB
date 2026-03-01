-- ================================================================
-- FAQ_ITEM_DELETE: FAQ sorusu soft delete
-- ================================================================

DROP FUNCTION IF EXISTS content.faq_item_delete(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION content.faq_item_delete(
    p_id                INTEGER,            -- FAQ item ID
    p_user_id           INTEGER             -- İşlemi yapan kullanıcı
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'error.faq.item-id-required';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM content.faq_items WHERE id = p_id AND is_active = TRUE) THEN
        RAISE EXCEPTION 'error.faq.item-not-found';
    END IF;

    UPDATE content.faq_items
    SET is_active = FALSE, updated_by = p_user_id, updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION content.faq_item_delete(INTEGER, INTEGER) IS 'Soft delete FAQ item.';

-- ================================================================
-- FAQ_ITEM_DELETE: SSS maddesi sil (Backoffice)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır
-- ================================================================

DROP FUNCTION IF EXISTS content.faq_item_delete(INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION content.faq_item_delete(
    p_id INTEGER,
    p_operator_id INTEGER DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM content.faq_items WHERE id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.faq-item.not-found';
    END IF;

    -- İlişkili translations sil
    DELETE FROM content.faq_item_translations WHERE faq_item_id = p_id;

    -- Item'ı sil
    DELETE FROM content.faq_items WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION content.faq_item_delete IS 'Deletes a FAQ item and its translations. Auth check done in Core DB.';

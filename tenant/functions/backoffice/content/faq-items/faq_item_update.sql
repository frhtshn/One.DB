-- ================================================================
-- FAQ_ITEM_UPDATE: SSS maddesi güncelle (Backoffice)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır
-- Partial update destekler (NULL = değiştirme)
-- ================================================================

DROP FUNCTION IF EXISTS content.faq_item_update(INTEGER, INTEGER, INTEGER, BOOLEAN, BOOLEAN, INTEGER);

CREATE OR REPLACE FUNCTION content.faq_item_update(
    p_id INTEGER,
    p_category_id INTEGER DEFAULT NULL,
    p_sort_order INTEGER DEFAULT NULL,
    p_is_featured BOOLEAN DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL,
    -- Audit
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

    -- Kategori kontrolü
    IF p_category_id IS NOT NULL AND NOT EXISTS(
        SELECT 1 FROM content.faq_categories WHERE id = p_category_id AND is_active = TRUE
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.faq-category.not-found';
    END IF;

    -- Update
    UPDATE content.faq_items
    SET
        category_id = COALESCE(p_category_id, category_id),
        sort_order = COALESCE(p_sort_order, sort_order),
        is_featured = COALESCE(p_is_featured, is_featured),
        is_active = COALESCE(p_is_active, is_active),
        updated_at = NOW(),
        updated_by = p_operator_id
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION content.faq_item_update IS 'Updates a FAQ item. Partial update supported. Auth check done in Core DB.';

-- ================================================================
-- FAQ_ITEM_CREATE: Yeni SSS maddesi oluştur (Backoffice)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır
-- p_operator_id: Core DB user ID (audit için)
-- ================================================================

DROP FUNCTION IF EXISTS content.faq_item_create(INTEGER, INTEGER, BOOLEAN, INTEGER);

CREATE OR REPLACE FUNCTION content.faq_item_create(
    p_category_id INTEGER,
    p_sort_order INTEGER DEFAULT 0,
    p_is_featured BOOLEAN DEFAULT FALSE,
    -- Audit
    p_operator_id INTEGER DEFAULT NULL
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id INTEGER;
BEGIN
    -- Kategori kontrolü
    IF p_category_id IS NOT NULL AND NOT EXISTS(
        SELECT 1 FROM content.faq_categories WHERE id = p_category_id AND is_active = TRUE
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.faq-category.not-found';
    END IF;

    -- Insert
    INSERT INTO content.faq_items (
        category_id, sort_order, is_featured,
        view_count, helpful_count, not_helpful_count,
        is_active, created_at, created_by
    )
    VALUES (
        p_category_id, p_sort_order, p_is_featured,
        0, 0, 0,
        TRUE, NOW(), p_operator_id
    )
    RETURNING id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION content.faq_item_create IS 'Creates a new FAQ item. Auth check done in Core DB.';

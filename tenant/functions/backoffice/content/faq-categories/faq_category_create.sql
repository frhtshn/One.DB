-- ================================================================
-- FAQ_CATEGORY_CREATE: Yeni SSS kategorisi oluştur (Backoffice)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır
-- p_operator_id: Core DB user ID (audit için)
-- ================================================================

DROP FUNCTION IF EXISTS content.faq_category_create(VARCHAR, VARCHAR, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION content.faq_category_create(
    p_code VARCHAR(50),
    p_icon VARCHAR(100) DEFAULT NULL,
    p_sort_order INTEGER DEFAULT 0,
    -- Audit
    p_operator_id INTEGER DEFAULT NULL
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id INTEGER;
BEGIN
    -- Kod benzersizlik kontrolü
    IF EXISTS(SELECT 1 FROM content.faq_categories WHERE code = p_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.faq-category.code-exists';
    END IF;

    -- Insert
    INSERT INTO content.faq_categories (
        code, icon, sort_order,
        is_active, created_at, created_by
    )
    VALUES (
        p_code, p_icon, p_sort_order,
        TRUE, NOW(), p_operator_id
    )
    RETURNING id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION content.faq_category_create IS 'Creates a new FAQ category. Auth check done in Core DB.';

-- ================================================================
-- PROMOTION_TYPE_CREATE: Yeni promosyon türü oluştur (Backoffice)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır
-- p_operator_id: Core DB user ID (audit için)
-- ================================================================

DROP FUNCTION IF EXISTS content.promotion_type_create(VARCHAR, VARCHAR, VARCHAR, VARCHAR, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION content.promotion_type_create(
    p_code VARCHAR(50),
    p_icon VARCHAR(50) DEFAULT NULL,
    p_color VARCHAR(20) DEFAULT NULL,
    p_badge_text VARCHAR(30) DEFAULT NULL,
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
    IF EXISTS(SELECT 1 FROM content.promotion_types WHERE code = p_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.promotion-type.code-exists';
    END IF;

    -- Insert
    INSERT INTO content.promotion_types (
        code, icon, color, badge_text, sort_order,
        is_active, created_at, created_by
    )
    VALUES (
        p_code, p_icon, p_color, p_badge_text, p_sort_order,
        TRUE, NOW(), p_operator_id
    )
    RETURNING id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION content.promotion_type_create IS 'Creates a new promotion type. Auth check done in Core DB.';

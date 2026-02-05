-- ================================================================
-- PROMOTION_CREATE: Yeni promosyon oluştur (Backoffice)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır (user_assert_access_tenant)
-- p_operator_id: Core DB user ID (audit için)
-- ================================================================

DROP FUNCTION IF EXISTS content.promotion_create(
    VARCHAR, INTEGER, INTEGER, NUMERIC, NUMERIC,
    TIMESTAMP, TIMESTAMP, INTEGER, BOOLEAN, BOOLEAN, INTEGER
);

CREATE OR REPLACE FUNCTION content.promotion_create(
    p_code VARCHAR(50),
    p_promotion_type_id INTEGER,
    p_bonus_id INTEGER DEFAULT NULL,
    p_min_deposit NUMERIC(18,2) DEFAULT NULL,
    p_max_deposit NUMERIC(18,2) DEFAULT NULL,
    p_start_date TIMESTAMP DEFAULT NULL,
    p_end_date TIMESTAMP DEFAULT NULL,
    p_sort_order INTEGER DEFAULT 0,
    p_is_featured BOOLEAN DEFAULT FALSE,
    p_is_new_members_only BOOLEAN DEFAULT FALSE,
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
    IF EXISTS(SELECT 1 FROM content.promotions WHERE code = p_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.promotion.code-exists';
    END IF;

    -- Tarih kontrolü
    IF p_start_date IS NOT NULL AND p_end_date IS NOT NULL AND p_start_date > p_end_date THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.promotion.invalid-date-range';
    END IF;

    -- Promotion type kontrolü
    IF NOT EXISTS(SELECT 1 FROM content.promotion_types WHERE id = p_promotion_type_id AND is_active = TRUE) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.promotion-type.not-found';
    END IF;

    -- Insert
    INSERT INTO content.promotions (
        code, promotion_type_id, bonus_id, min_deposit, max_deposit,
        start_date, end_date, sort_order, is_featured, is_new_members_only,
        is_active, created_at, created_by
    )
    VALUES (
        p_code, p_promotion_type_id, p_bonus_id, p_min_deposit, p_max_deposit,
        p_start_date, p_end_date, p_sort_order, p_is_featured, p_is_new_members_only,
        TRUE, NOW(), p_operator_id
    )
    RETURNING id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION content.promotion_create IS 'Creates a new promotion. Auth check done in Core DB. p_operator_id is Core DB user ID.';

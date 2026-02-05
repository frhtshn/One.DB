-- ================================================================
-- PROMOTION_UPDATE: Promosyon güncelle (Backoffice)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır (user_assert_access_tenant)
-- Partial update destekler (NULL = değiştirme)
-- ================================================================

DROP FUNCTION IF EXISTS content.promotion_update(
    INTEGER, VARCHAR, INTEGER, INTEGER, NUMERIC, NUMERIC,
    TIMESTAMP, TIMESTAMP, INTEGER, BOOLEAN, BOOLEAN, BOOLEAN, INTEGER
);

CREATE OR REPLACE FUNCTION content.promotion_update(
    p_id INTEGER,
    p_code VARCHAR(50) DEFAULT NULL,
    p_promotion_type_id INTEGER DEFAULT NULL,
    p_bonus_id INTEGER DEFAULT NULL,
    p_min_deposit NUMERIC(18,2) DEFAULT NULL,
    p_max_deposit NUMERIC(18,2) DEFAULT NULL,
    p_start_date TIMESTAMP DEFAULT NULL,
    p_end_date TIMESTAMP DEFAULT NULL,
    p_sort_order INTEGER DEFAULT NULL,
    p_is_featured BOOLEAN DEFAULT NULL,
    p_is_new_members_only BOOLEAN DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL,
    -- Audit
    p_operator_id INTEGER DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM content.promotions WHERE id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.promotion.not-found';
    END IF;

    -- Kod benzersizlik kontrolü
    IF p_code IS NOT NULL AND EXISTS(
        SELECT 1 FROM content.promotions WHERE code = p_code AND id != p_id
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.promotion.code-exists';
    END IF;

    -- Promotion type kontrolü
    IF p_promotion_type_id IS NOT NULL AND NOT EXISTS(
        SELECT 1 FROM content.promotion_types WHERE id = p_promotion_type_id AND is_active = TRUE
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.promotion-type.not-found';
    END IF;

    -- Update
    UPDATE content.promotions
    SET
        code = COALESCE(p_code, code),
        promotion_type_id = COALESCE(p_promotion_type_id, promotion_type_id),
        bonus_id = COALESCE(p_bonus_id, bonus_id),
        min_deposit = COALESCE(p_min_deposit, min_deposit),
        max_deposit = COALESCE(p_max_deposit, max_deposit),
        start_date = COALESCE(p_start_date, start_date),
        end_date = COALESCE(p_end_date, end_date),
        sort_order = COALESCE(p_sort_order, sort_order),
        is_featured = COALESCE(p_is_featured, is_featured),
        is_new_members_only = COALESCE(p_is_new_members_only, is_new_members_only),
        is_active = COALESCE(p_is_active, is_active),
        updated_at = NOW(),
        updated_by = p_operator_id
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION content.promotion_update IS 'Updates a promotion. Partial update supported. Auth check done in Core DB.';

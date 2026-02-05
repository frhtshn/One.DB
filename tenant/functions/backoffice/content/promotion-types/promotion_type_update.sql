-- ================================================================
-- PROMOTION_TYPE_UPDATE: Promosyon türü güncelle (Backoffice)
-- ================================================================
-- NOT: Yetki kontrolü Core DB'de yapılır
-- Partial update destekler (NULL = değiştirme)
-- ================================================================

DROP FUNCTION IF EXISTS content.promotion_type_update(INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR, INTEGER, BOOLEAN, INTEGER);

CREATE OR REPLACE FUNCTION content.promotion_type_update(
    p_id INTEGER,
    p_code VARCHAR(50) DEFAULT NULL,
    p_icon VARCHAR(50) DEFAULT NULL,
    p_color VARCHAR(20) DEFAULT NULL,
    p_badge_text VARCHAR(30) DEFAULT NULL,
    p_sort_order INTEGER DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL,
    -- Audit
    p_operator_id INTEGER DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM content.promotion_types WHERE id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.promotion-type.not-found';
    END IF;

    -- Kod benzersizlik kontrolü
    IF p_code IS NOT NULL AND EXISTS(
        SELECT 1 FROM content.promotion_types WHERE code = p_code AND id != p_id
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.promotion-type.code-exists';
    END IF;

    -- Update
    UPDATE content.promotion_types
    SET
        code = COALESCE(p_code, code),
        icon = COALESCE(p_icon, icon),
        color = COALESCE(p_color, color),
        badge_text = COALESCE(p_badge_text, badge_text),
        sort_order = COALESCE(p_sort_order, sort_order),
        is_active = COALESCE(p_is_active, is_active),
        updated_at = NOW(),
        updated_by = p_operator_id
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION content.promotion_type_update IS 'Updates a promotion type. Partial update supported. Auth check done in Core DB.';

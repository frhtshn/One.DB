-- ================================================================
-- BONUS_TYPE_UPDATE: Bonus tipi güncelle
-- ================================================================
-- COALESCE pattern: NULL = mevcut değeri koru.
-- type_code değiştirilebilir (unique kontrolü yapılır).
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_type_update(BIGINT, VARCHAR, VARCHAR, TEXT, VARCHAR, VARCHAR, BOOLEAN);

CREATE OR REPLACE FUNCTION bonus.bonus_type_update(
    p_id BIGINT,
    p_type_code VARCHAR(50) DEFAULT NULL,
    p_type_name VARCHAR(255) DEFAULT NULL,
    p_description TEXT DEFAULT NULL,
    p_category VARCHAR(50) DEFAULT NULL,
    p_value_type VARCHAR(30) DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_current RECORD;
BEGIN
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-type.id-required';
    END IF;

    SELECT id, tenant_id, type_code INTO v_current
    FROM bonus.bonus_types WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.bonus-type.not-found';
    END IF;

    -- type_code değişiyorsa unique kontrolü
    IF p_type_code IS NOT NULL AND UPPER(TRIM(p_type_code)) != v_current.type_code THEN
        IF EXISTS (
            SELECT 1 FROM bonus.bonus_types
            WHERE tenant_id IS NOT DISTINCT FROM v_current.tenant_id
              AND type_code = UPPER(TRIM(p_type_code))
              AND id != p_id
        ) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.bonus-type.code-exists';
        END IF;
    END IF;

    UPDATE bonus.bonus_types SET
        type_code = COALESCE(UPPER(TRIM(NULLIF(p_type_code, ''))), type_code),
        type_name = COALESCE(TRIM(NULLIF(p_type_name, '')), type_name),
        description = COALESCE(p_description, description),
        category = COALESCE(LOWER(TRIM(NULLIF(p_category, ''))), category),
        value_type = COALESCE(LOWER(TRIM(NULLIF(p_value_type, ''))), value_type),
        is_active = COALESCE(p_is_active, is_active),
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION bonus.bonus_type_update(BIGINT, VARCHAR, VARCHAR, TEXT, VARCHAR, VARCHAR, BOOLEAN) IS 'Updates a bonus type definition. COALESCE pattern preserves existing values when NULL is passed.';

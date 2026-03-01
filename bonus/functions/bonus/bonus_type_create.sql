-- ================================================================
-- BONUS_TYPE_CREATE: Bonus tipi oluştur
-- ================================================================
-- Bonus kategorisi tanımlar: deposit_match, free_spin, cashback vb.
-- client_id NULL ise platform seviyesi, değer ise client'a özel.
-- Unique: (client_id, type_code).
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_type_create(BIGINT, VARCHAR, VARCHAR, TEXT, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION bonus.bonus_type_create(
    p_client_id BIGINT,
    p_type_code VARCHAR(50),
    p_type_name VARCHAR(255),
    p_description TEXT DEFAULT NULL,
    p_category VARCHAR(50) DEFAULT NULL,
    p_value_type VARCHAR(30) DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_new_id BIGINT;
BEGIN
    -- Zorunlu alan kontrolü
    IF p_type_code IS NULL OR TRIM(p_type_code) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-type.code-required';
    END IF;

    IF p_type_name IS NULL OR TRIM(p_type_name) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-type.name-required';
    END IF;

    IF p_category IS NULL OR TRIM(p_category) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-type.category-required';
    END IF;

    IF p_value_type IS NULL OR TRIM(p_value_type) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-type.value-type-required';
    END IF;

    -- Unique kod kontrolü
    IF EXISTS (
        SELECT 1 FROM bonus.bonus_types
        WHERE client_id IS NOT DISTINCT FROM p_client_id
          AND type_code = UPPER(TRIM(p_type_code))
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.bonus-type.code-exists';
    END IF;

    INSERT INTO bonus.bonus_types (
        client_id, type_code, type_name, description,
        category, value_type, is_active, created_at, updated_at
    ) VALUES (
        p_client_id,
        UPPER(TRIM(p_type_code)),
        TRIM(p_type_name),
        p_description,
        LOWER(TRIM(p_category)),
        LOWER(TRIM(p_value_type)),
        true,
        NOW(), NOW()
    )
    RETURNING id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION bonus.bonus_type_create(BIGINT, VARCHAR, VARCHAR, TEXT, VARCHAR, VARCHAR) IS 'Creates a bonus type definition (deposit_match, free_spin, cashback, etc). Unique by (client_id, type_code). No auth check — handled by Core backend.';

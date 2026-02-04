-- ================================================================
-- PROVIDER_TYPE_CREATE: Yeni provider tipi oluşturur
-- Sadece SuperAdmin kullanabilir (IDOR korumalı)
-- ================================================================

DROP FUNCTION IF EXISTS catalog.provider_type_create(BIGINT, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION catalog.provider_type_create(
    p_caller_id BIGINT,
    p_code VARCHAR(30),
    p_name VARCHAR(100)
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_code VARCHAR(30);
    v_name VARCHAR(100);
    v_new_id BIGINT;
BEGIN
    -- SuperAdmin check
    PERFORM security.user_assert_superadmin(p_caller_id);

    -- Kod kontrolü
    IF p_code IS NULL OR LENGTH(TRIM(p_code)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider-type.code-invalid';
    END IF;

    -- İsim kontrolü
    IF p_name IS NULL OR LENGTH(TRIM(p_name)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider-type.name-invalid';
    END IF;

    v_code := UPPER(TRIM(p_code));
    v_name := TRIM(p_name);

    -- Mevcut kod kontrolü
    IF EXISTS(SELECT 1 FROM catalog.provider_types pt WHERE pt.provider_type_code = v_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.provider-type.code-exists';
    END IF;

    -- Ekle
    INSERT INTO catalog.provider_types (provider_type_code, provider_type_name, created_at)
    VALUES (v_code, v_name, NOW())
    RETURNING catalog.provider_types.id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION catalog.provider_type_create IS 'Creates a new provider type. SuperAdmin only.';

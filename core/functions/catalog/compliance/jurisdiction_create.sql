-- ================================================================
-- JURISDICTION_CREATE: Yeni jurisdiction oluşturur
-- Platform Admin (SuperAdmin + Admin) kullanabilir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.jurisdiction_create(BIGINT, VARCHAR, VARCHAR, CHAR(2), VARCHAR, VARCHAR, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION catalog.jurisdiction_create(
    p_caller_id BIGINT,
    p_code VARCHAR(20),
    p_name VARCHAR(100),
    p_country_code CHAR(2),
    p_authority_type VARCHAR(30),
    p_region VARCHAR(50) DEFAULT NULL,
    p_website_url VARCHAR(255) DEFAULT NULL,
    p_license_prefix VARCHAR(20) DEFAULT NULL
)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_code VARCHAR(20);
    v_name VARCHAR(100);
    v_new_id INT;
BEGIN
    -- Platform Admin kontrolü (SuperAdmin veya Admin)
    IF NOT EXISTS(
        SELECT 1 FROM security.user_roles ur
        JOIN security.roles r ON ur.role_id = r.id
        WHERE ur.user_id = p_caller_id
          AND ur.tenant_id IS NULL
          AND r.code IN ('superadmin', 'admin')
          AND r.status = 1
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

    -- Kod kontrolü
    IF p_code IS NULL OR LENGTH(TRIM(p_code)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.jurisdiction.code-invalid';
    END IF;

    -- İsim kontrolü
    IF p_name IS NULL OR LENGTH(TRIM(p_name)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.jurisdiction.name-invalid';
    END IF;

    -- Ülke kodu kontrolü
    IF p_country_code IS NULL OR LENGTH(TRIM(p_country_code)) != 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.jurisdiction.country-code-invalid';
    END IF;

    -- Otorite tipi kontrolü
    IF p_authority_type IS NULL OR p_authority_type NOT IN ('national', 'regional', 'offshore') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.jurisdiction.authority-type-invalid';
    END IF;

    v_code := UPPER(TRIM(p_code));
    v_name := TRIM(p_name);

    -- Mevcut kod kontrolü
    IF EXISTS(SELECT 1 FROM catalog.jurisdictions j WHERE j.code = v_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.jurisdiction.code-exists';
    END IF;

    -- Ekle
    INSERT INTO catalog.jurisdictions (
        code, name, country_code, region, authority_type,
        website_url, license_prefix, is_active, created_at, updated_at
    )
    VALUES (
        v_code, v_name, UPPER(p_country_code), TRIM(p_region), p_authority_type,
        TRIM(p_website_url), TRIM(p_license_prefix), TRUE, NOW(), NOW()
    )
    RETURNING catalog.jurisdictions.id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION catalog.jurisdiction_create IS 'Creates a new jurisdiction. Platform Admin only.';

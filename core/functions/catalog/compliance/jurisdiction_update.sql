-- ================================================================
-- JURISDICTION_UPDATE: Jurisdiction günceller
-- Platform Admin (SuperAdmin + Admin) kullanabilir
-- NULL geçilen alanlar güncellenmez (COALESCE pattern)
-- ================================================================

DROP FUNCTION IF EXISTS catalog.jurisdiction_update(BIGINT, INT, VARCHAR, VARCHAR, CHAR(2), VARCHAR, VARCHAR, VARCHAR, VARCHAR, BOOLEAN);

CREATE OR REPLACE FUNCTION catalog.jurisdiction_update(
    p_caller_id BIGINT,
    p_id INT,
    p_code VARCHAR(20) DEFAULT NULL,
    p_name VARCHAR(100) DEFAULT NULL,
    p_country_code CHAR(2) DEFAULT NULL,
    p_region VARCHAR(50) DEFAULT NULL,
    p_authority_type VARCHAR(30) DEFAULT NULL,
    p_website_url VARCHAR(255) DEFAULT NULL,
    p_license_prefix VARCHAR(20) DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_code VARCHAR(20);
    v_existing_id INT;
BEGIN
    -- Platform Admin check
    PERFORM security.user_assert_platform_admin(p_caller_id);

    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.jurisdiction.id-required';
    END IF;

    -- Mevcut kayıt kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.jurisdictions j WHERE j.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.jurisdiction.not-found';
    END IF;

    -- Kod değişiyorsa validasyon
    IF p_code IS NOT NULL THEN
        IF LENGTH(TRIM(p_code)) < 2 THEN
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.jurisdiction.code-invalid';
        END IF;

        v_code := UPPER(TRIM(p_code));

        -- Benzersizlik kontrolü
        SELECT j.id INTO v_existing_id
        FROM catalog.jurisdictions j
        WHERE j.code = v_code AND j.id != p_id;

        IF v_existing_id IS NOT NULL THEN
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.jurisdiction.code-exists';
        END IF;
    END IF;

    -- İsim değişiyorsa validasyon
    IF p_name IS NOT NULL AND LENGTH(TRIM(p_name)) < 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.jurisdiction.name-invalid';
    END IF;

    -- Ülke kodu değişiyorsa validasyon
    IF p_country_code IS NOT NULL AND LENGTH(TRIM(p_country_code)) != 2 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.jurisdiction.country-code-invalid';
    END IF;

    -- Otorite tipi değişiyorsa validasyon
    IF p_authority_type IS NOT NULL AND p_authority_type NOT IN ('national', 'regional', 'offshore') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.jurisdiction.authority-type-invalid';
    END IF;

    -- Güncelle
    UPDATE catalog.jurisdictions SET
        code = COALESCE(UPPER(TRIM(p_code)), code),
        name = COALESCE(TRIM(p_name), name),
        country_code = COALESCE(UPPER(p_country_code), country_code),
        region = COALESCE(TRIM(p_region), region),
        authority_type = COALESCE(p_authority_type, authority_type),
        website_url = COALESCE(TRIM(p_website_url), website_url),
        license_prefix = COALESCE(TRIM(p_license_prefix), license_prefix),
        is_active = COALESCE(p_is_active, is_active),
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.jurisdiction_update IS 'Updates a jurisdiction. Platform Admin only. NULL values keep existing data.';

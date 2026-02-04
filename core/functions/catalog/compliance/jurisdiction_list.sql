-- ================================================================
-- JURISDICTION_LIST: Lisans otoritelerini listeler
-- Platform Admin (SuperAdmin + Admin) erişebilir
-- Opsiyonel country_code ve is_active filtresi
-- ================================================================

DROP FUNCTION IF EXISTS catalog.jurisdiction_list(BIGINT, CHAR(2), BOOLEAN);

CREATE OR REPLACE FUNCTION catalog.jurisdiction_list(
    p_caller_id BIGINT,
    p_country_code CHAR(2) DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS TABLE(
    id INT,
    code VARCHAR(20),
    name VARCHAR(100),
    country_code CHAR(2),
    region VARCHAR(50),
    authority_type VARCHAR(30),
    website_url VARCHAR(255),
    license_prefix VARCHAR(20),
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    -- Platform Admin check
    PERFORM security.user_assert_platform_admin(p_caller_id);

    RETURN QUERY
    SELECT
        j.id,
        j.code,
        j.name,
        j.country_code,
        j.region,
        j.authority_type,
        j.website_url,
        j.license_prefix,
        j.is_active,
        j.created_at,
        j.updated_at
    FROM catalog.jurisdictions j
    WHERE (p_country_code IS NULL OR j.country_code = p_country_code)
      AND (p_is_active IS NULL OR j.is_active = p_is_active)
    ORDER BY j.name;
END;
$$;

COMMENT ON FUNCTION catalog.jurisdiction_list IS 'Lists jurisdictions. Platform Admin only. Optional country_code and is_active filters.';

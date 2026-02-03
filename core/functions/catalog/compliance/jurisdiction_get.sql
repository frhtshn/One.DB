-- ================================================================
-- JURISDICTION_GET: Tekil jurisdiction getirir
-- Platform Admin (SuperAdmin + Admin) erişebilir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.jurisdiction_get(BIGINT, INT);

CREATE OR REPLACE FUNCTION catalog.jurisdiction_get(
    p_caller_id BIGINT,
    p_id INT
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

    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.jurisdiction.id-required';
    END IF;

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
    WHERE j.id = p_id;

    -- Bulunamadı kontrolü
    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.jurisdiction.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION catalog.jurisdiction_get IS 'Gets a single jurisdiction by ID. Platform Admin only.';

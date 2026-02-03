-- ================================================================
-- PROVIDER_TYPE_GET: Tekil provider tipi getirir
-- Sadece SuperAdmin erişebilir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.provider_type_get(BIGINT);
DROP FUNCTION IF EXISTS catalog.provider_type_get(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION catalog.provider_type_get(
    p_caller_id BIGINT,
    p_id BIGINT
)
RETURNS TABLE(
    id BIGINT,
    provider_type_code VARCHAR(30),
    provider_type_name VARCHAR(100),
    created_at TIMESTAMP
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
          AND r.code = 'superadmin'
          AND r.status = 1
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider-type.id-required';
    END IF;

    RETURN QUERY
    SELECT
        pt.id,
        pt.provider_type_code,
        pt.provider_type_name,
        pt.created_at
    FROM catalog.provider_types pt
    WHERE pt.id = p_id;

    -- Bulunamadı kontrolü
    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.provider-type.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION catalog.provider_type_get IS 'Gets a single provider type by ID. SuperAdmin only.';

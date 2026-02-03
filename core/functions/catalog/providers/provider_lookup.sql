-- ================================================================
-- PROVIDER_LOOKUP: Provider dropdown için basit liste
-- SuperAdmin erişebilir (provider_list ile tutarlı)
-- Opsiyonel provider_type_id filtresi
-- ================================================================

DROP FUNCTION IF EXISTS catalog.provider_lookup(BIGINT);
DROP FUNCTION IF EXISTS catalog.provider_lookup(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION catalog.provider_lookup(
    p_caller_id BIGINT,
    p_type_id BIGINT DEFAULT NULL
)
RETURNS TABLE(
    id BIGINT,
    code VARCHAR(50),
    name VARCHAR(255),
    type_id BIGINT,
    type_code VARCHAR(30),
    type_name VARCHAR(100),
    is_active BOOLEAN
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    -- SuperAdmin kontrolü
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

    RETURN QUERY
    SELECT
        p.id,
        p.provider_code AS code,
        p.provider_name AS name,
        p.provider_type_id AS type_id,
        pt.provider_type_code AS type_code,
        pt.provider_type_name AS type_name,
        p.is_active
    FROM catalog.providers p
    JOIN catalog.provider_types pt ON pt.id = p.provider_type_id
    WHERE (p_type_id IS NULL OR p.provider_type_id = p_type_id)
    ORDER BY pt.provider_type_name, p.provider_name;
END;
$$;

COMMENT ON FUNCTION catalog.provider_lookup(BIGINT, BIGINT) IS 'Returns provider list for dropdowns. Optional type_id filter. SuperAdmin only.';

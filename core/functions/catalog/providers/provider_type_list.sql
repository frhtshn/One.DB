-- ================================================================
-- PROVIDER_TYPE_LIST: Tüm provider tiplerini listeler
-- Sadece SuperAdmin erişebilir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.provider_type_list();
DROP FUNCTION IF EXISTS catalog.provider_type_list(BIGINT);

CREATE OR REPLACE FUNCTION catalog.provider_type_list(
    p_caller_id BIGINT
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
        pt.id,
        pt.provider_type_code,
        pt.provider_type_name,
        pt.created_at
    FROM catalog.provider_types pt
    ORDER BY pt.provider_type_name;
END;
$$;

COMMENT ON FUNCTION catalog.provider_type_list IS 'Lists all provider types. SuperAdmin only.';

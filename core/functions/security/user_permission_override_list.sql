-- ================================================================
-- USER_PERMISSION_OVERRIDE_LIST - Override Listesi
-- ================================================================

DROP FUNCTION IF EXISTS security.user_permission_override_list(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.user_permission_override_list(
    p_user_id BIGINT,
    p_tenant_id BIGINT DEFAULT NULL
)
RETURNS TABLE (
    permission_code VARCHAR(100),
    permission_name VARCHAR(150),
    category VARCHAR(50),
    is_granted BOOLEAN,
    tenant_id BIGINT,
    reason VARCHAR(500),
    assigned_by BIGINT,
    assigned_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.code AS permission_code,
        p.name AS permission_name,
        p.category,
        up.is_granted,
        up.tenant_id,
        up.reason,
        up.assigned_by,
        up.assigned_at,
        up.expires_at
    FROM security.user_permission_overrides up
    JOIN security.permissions p ON up.permission_id = p.id
    WHERE up.user_id = p_user_id
      AND (p_tenant_id IS NULL OR up.tenant_id IS NULL OR up.tenant_id = p_tenant_id)
      AND (up.expires_at IS NULL OR up.expires_at > NOW())
    ORDER BY p.category, p.code;
END;
$$;

COMMENT ON FUNCTION security.user_permission_override_list IS 'Lists active permission overrides for a user';

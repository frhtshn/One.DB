-- =============================================
-- 16. USER_TENANT_ROLE_LIST: Tenant-specific rol listesi
-- Returns: JSONB array - dogrudan rol listesi
-- =============================================

DROP FUNCTION IF EXISTS security.user_tenant_role_list(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.user_tenant_role_list(
    p_user_id BIGINT,
    p_tenant_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_roles JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'code', r.code,
        'name', r.name,
        'assignedAt', utr.assigned_at,
        'assignedBy', utr.assigned_by
    )), '[]'::jsonb)
    INTO v_roles
    FROM security.user_tenant_roles utr
    JOIN security.roles r ON r.id = utr.role_id
    WHERE utr.user_id = p_user_id
      AND utr.tenant_id = p_tenant_id
      AND r.status = 1;

    -- Dogrudan array don
    RETURN v_roles;
END;
$$;

COMMENT ON FUNCTION security.user_tenant_role_list IS 'Lists tenant-specific roles for a user. Returns direct JSON array.';

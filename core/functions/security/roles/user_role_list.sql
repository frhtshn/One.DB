-- =============================================
-- 15. USER_ROLE_LIST: Kullanici rol listesi
-- Returns: JSONB {globalRoles, tenantRoles}
-- =============================================

DROP FUNCTION IF EXISTS security.user_role_list(BIGINT);

CREATE OR REPLACE FUNCTION security.user_role_list(
    p_user_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_exists BOOLEAN;
    v_global_roles JSONB;
    v_tenant_roles JSONB;
BEGIN
    -- Check user
    SELECT EXISTS(SELECT 1 FROM security.users WHERE id = p_user_id)
    INTO v_user_exists;

    IF NOT v_user_exists THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- Get global roles
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'code', r.code,
        'name', r.name,
        'assignedAt', ur.assigned_at,
        'assignedBy', ur.assigned_by
    )), '[]'::jsonb)
    INTO v_global_roles
    FROM security.user_roles ur
    JOIN security.roles r ON r.id = ur.role_id
    WHERE ur.user_id = p_user_id AND r.status = 1;

    -- Get tenant roles
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'tenantId', utr.tenant_id,
        'code', r.code,
        'name', r.name,
        'assignedAt', utr.assigned_at,
        'assignedBy', utr.assigned_by
    )), '[]'::jsonb)
    INTO v_tenant_roles
    FROM security.user_tenant_roles utr
    JOIN security.roles r ON r.id = utr.role_id
    WHERE utr.user_id = p_user_id AND r.status = 1;

    RETURN jsonb_build_object(
        'globalRoles', v_global_roles,
        'tenantRoles', v_tenant_roles
    );
END;
$$;

COMMENT ON FUNCTION security.user_role_list IS 'Lists usage roles (global and tenant-specific).';

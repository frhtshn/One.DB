-- =============================================
-- 13. USER_TENANT_ROLE_ASSIGN: Tenant-specific rol ata
-- Returns: TABLE(already_assigned) - idempotent bilgi
-- =============================================

DROP FUNCTION IF EXISTS security.user_tenant_role_assign(BIGINT, BIGINT, VARCHAR, BIGINT);

CREATE OR REPLACE FUNCTION security.user_tenant_role_assign(
    p_user_id BIGINT,
    p_tenant_id BIGINT,
    p_role_code VARCHAR,
    p_assigned_by BIGINT DEFAULT NULL
)
RETURNS TABLE(already_assigned BOOLEAN)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_exists BOOLEAN;
    v_role_id BIGINT;
    v_role_status SMALLINT;
    v_role_code VARCHAR;
    v_already_assigned BOOLEAN;
BEGIN
    -- Check user
    SELECT EXISTS(SELECT 1 FROM security.users WHERE id = p_user_id AND status = 1)
    INTO v_user_exists;

    IF NOT v_user_exists THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- Normalize role code
    v_role_code := LOWER(TRIM(p_role_code));

    -- Protect system roles
    IF security.is_system_role(v_role_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.role.system-protected';
    END IF;

    -- Check role
    SELECT id, status INTO v_role_id, v_role_status
    FROM security.roles
    WHERE code = v_role_code;

    IF v_role_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.role.not-found';
    END IF;

    IF v_role_status = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.role.deleted';
    END IF;

    -- Check if already assigned
    SELECT EXISTS(
        SELECT 1 FROM security.user_tenant_roles
        WHERE user_id = p_user_id AND tenant_id = p_tenant_id AND role_id = v_role_id
    ) INTO v_already_assigned;

    IF NOT v_already_assigned THEN
        -- Assign
        INSERT INTO security.user_tenant_roles (user_id, tenant_id, role_id, assigned_at, assigned_by)
        VALUES (p_user_id, p_tenant_id, v_role_id, NOW(), p_assigned_by)
        ON CONFLICT (user_id, tenant_id, role_id) DO NOTHING;
    END IF;

    RETURN QUERY SELECT v_already_assigned;
END;
$$;

COMMENT ON FUNCTION security.user_tenant_role_assign IS 'Assigns a tenant-specific role to a user. Idempotent.';

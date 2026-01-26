-- =============================================
-- 14. USER_TENANT_ROLE_REMOVE: Tenant-specific rol kaldir
-- Returns: TABLE(removed) - silme bilgisi
-- =============================================

DROP FUNCTION IF EXISTS security.user_tenant_role_remove(BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION security.user_tenant_role_remove(
    p_user_id BIGINT,
    p_tenant_id BIGINT,
    p_role_code VARCHAR
)
RETURNS TABLE(removed BOOLEAN)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_role_id BIGINT;
    v_deleted_count INT;
BEGIN
    -- Get role id
    SELECT id INTO v_role_id
    FROM security.roles
    WHERE code = LOWER(p_role_code);

    IF v_role_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.role.not-found';
    END IF;

    -- Remove
    DELETE FROM security.user_tenant_roles
    WHERE user_id = p_user_id AND tenant_id = p_tenant_id AND role_id = v_role_id;

    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

    RETURN QUERY SELECT v_deleted_count > 0;
END;
$$;

COMMENT ON FUNCTION security.user_tenant_role_remove IS 'Removes a tenant-specific role from a user.';

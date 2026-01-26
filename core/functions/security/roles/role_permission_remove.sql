-- =============================================
-- 9. ROLE_PERMISSION_REMOVE: Rolden permission kaldir
-- Returns: TABLE(removed) - silme bilgisi
-- =============================================

DROP FUNCTION IF EXISTS security.role_permission_remove(BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION security.role_permission_remove(
    p_role_id BIGINT,
    p_permission_code VARCHAR
)
RETURNS TABLE(removed BOOLEAN)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_role_exists BOOLEAN;
    v_role_code VARCHAR;
    v_permission_id BIGINT;
    v_deleted_count INT;
BEGIN
    -- Check role and get code
    SELECT EXISTS(SELECT 1 FROM security.roles WHERE id = p_role_id),
           (SELECT code FROM security.roles WHERE id = p_role_id)
    INTO v_role_exists, v_role_code;

    IF NOT v_role_exists THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.role.not-found';
    END IF;

    -- Protect system roles
    IF security.is_system_role(v_role_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.role.system-protected';
    END IF;

    -- Get permission id
    SELECT id INTO v_permission_id
    FROM security.permissions
    WHERE code = LOWER(p_permission_code);

    IF v_permission_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.permission.not-found';
    END IF;

    -- Remove
    DELETE FROM security.role_permissions
    WHERE role_id = p_role_id AND permission_id = v_permission_id;

    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

    RETURN QUERY SELECT v_deleted_count > 0;
END;
$$;

COMMENT ON FUNCTION security.role_permission_remove IS 'Removes a permission from a role. Returns removal status.';

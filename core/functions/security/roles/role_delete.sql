-- =============================================
-- 5. ROLE_DELETE: Soft delete
-- Returns: TABLE(affected_users) - Permission pattern
-- Birleşik user_roles: tenant_id IS NULL = global, tenant_id IS NOT NULL = tenant
-- =============================================

DROP FUNCTION IF EXISTS security.role_delete(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.role_delete(
    p_id BIGINT,
    p_deleted_by BIGINT DEFAULT NULL
)
RETURNS TABLE(affected_users INT)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_current_status SMALLINT;
    v_current_code VARCHAR;
    v_affected_users INT;
BEGIN
    -- Get current state
    SELECT status, code INTO v_current_status, v_current_code
    FROM security.roles
    WHERE id = p_id;

    IF v_current_status IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.role.not-found';
    END IF;

    IF v_current_status = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.role.delete.already-deleted';
    END IF;

    -- Protect system roles
    IF security.is_system_role(v_current_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.role.system-protected';
    END IF;

    -- Count affected users (birleşik user_roles)
    SELECT COUNT(DISTINCT user_id)
    INTO v_affected_users
    FROM security.user_roles
    WHERE role_id = p_id;

    -- Soft delete
    UPDATE security.roles
    SET
        status = 0,
        updated_at = NOW(),
        deleted_at = NOW(),
        deleted_by = p_deleted_by
    WHERE id = p_id;

    RETURN QUERY SELECT v_affected_users;
END;
$$;

COMMENT ON FUNCTION security.role_delete IS 'Soft deletes a role. System roles cannot be deleted. Returns affected user count. Uses unified user_roles table.';

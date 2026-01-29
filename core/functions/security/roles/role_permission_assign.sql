-- =============================================
-- 8. ROLE_PERMISSION_ASSIGN: Role permission ata
-- Returns: TABLE(already_assigned) - idempotent bilgi
-- =============================================

DROP FUNCTION IF EXISTS security.role_permission_assign(BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION security.role_permission_assign(
    p_role_id BIGINT,
    p_permission_code VARCHAR
)
RETURNS TABLE(already_assigned BOOLEAN)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_role_status SMALLINT;
    v_permission_id BIGINT;
    v_permission_status SMALLINT;
    v_already_assigned BOOLEAN;
BEGIN
    -- Check role
    SELECT status INTO v_role_status
    FROM security.roles
    WHERE id = p_role_id;

    IF v_role_status IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.role.not-found';
    END IF;

    IF v_role_status = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.role.deleted';
    END IF;


    -- Check permission
    SELECT id, status INTO v_permission_id, v_permission_status
    FROM security.permissions
    WHERE code = LOWER(p_permission_code);

    IF v_permission_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.permission.not-found';
    END IF;

    IF v_permission_status = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.permission.deleted';
    END IF;

    -- Check if already assigned
    SELECT EXISTS(
        SELECT 1 FROM security.role_permissions
        WHERE role_id = p_role_id AND permission_id = v_permission_id
    ) INTO v_already_assigned;

    IF NOT v_already_assigned THEN
        -- Assign
        INSERT INTO security.role_permissions (role_id, permission_id, created_at)
        VALUES (p_role_id, v_permission_id, NOW())
        ON CONFLICT (role_id, permission_id) DO NOTHING;
    END IF;

    RETURN QUERY SELECT v_already_assigned;
END;
$$;

COMMENT ON FUNCTION security.role_permission_assign IS 'Assigns a permission to a role. Idempotent. Returns already_assigned status.';

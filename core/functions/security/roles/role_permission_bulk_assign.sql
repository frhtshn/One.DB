-- =============================================
-- 10. ROLE_PERMISSION_BULK_ASSIGN: Toplu permission atama
-- Returns: JSONB {assignedCount, invalidCodes}
-- =============================================

DROP FUNCTION IF EXISTS security.role_permission_bulk_assign(BIGINT, VARCHAR[], BOOLEAN);

CREATE OR REPLACE FUNCTION security.role_permission_bulk_assign(
    p_role_id BIGINT,
    p_permission_codes VARCHAR[],
    p_replace_existing BOOLEAN DEFAULT FALSE
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_role_status SMALLINT;
    v_role_code VARCHAR;
    v_assigned_count INT := 0;
    v_invalid_codes VARCHAR[] := '{}';
    v_code VARCHAR;
    v_permission_id BIGINT;
    v_permission_status SMALLINT;
    v_row_count INT;
BEGIN
    -- Check role
    SELECT status, code INTO v_role_status, v_role_code
    FROM security.roles
    WHERE id = p_role_id;

    IF v_role_status IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.role.not-found';
    END IF;

    IF v_role_status = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.role.deleted';
    END IF;

    -- Protect system roles
    IF security.is_system_role(v_role_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.role.system-protected';
    END IF;

    -- Clear existing if replace mode
    IF p_replace_existing THEN
        DELETE FROM security.role_permissions WHERE role_id = p_role_id;
    END IF;

    -- Process each permission code
    FOREACH v_code IN ARRAY p_permission_codes
    LOOP
        SELECT id, status INTO v_permission_id, v_permission_status
        FROM security.permissions
        WHERE code = LOWER(v_code);

        IF v_permission_id IS NULL OR v_permission_status = 0 THEN
            v_invalid_codes := array_append(v_invalid_codes, v_code);
            CONTINUE;
        END IF;

        -- Insert if not exists
        INSERT INTO security.role_permissions (role_id, permission_id, created_at)
        VALUES (p_role_id, v_permission_id, NOW())
        ON CONFLICT (role_id, permission_id) DO NOTHING;

        GET DIAGNOSTICS v_row_count = ROW_COUNT;
        IF v_row_count > 0 THEN
            v_assigned_count := v_assigned_count + 1;
        END IF;
    END LOOP;

    RETURN jsonb_build_object(
        'assignedCount', v_assigned_count,
        'invalidCodes', to_jsonb(v_invalid_codes)
    );
END;
$$;

COMMENT ON FUNCTION security.role_permission_bulk_assign IS 'Bulk assigns permissions to a role. Returns assigned count and invalid codes.';

-- =============================================
-- 6. ROLE_RESTORE: Silinmis rolu geri yukle
-- Returns: VOID - Permission pattern
-- =============================================

DROP FUNCTION IF EXISTS security.role_restore(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.role_restore(
    p_id BIGINT,
    p_restored_by BIGINT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_current_status SMALLINT;
    v_current_code VARCHAR;
BEGIN
    SELECT status, code INTO v_current_status, v_current_code
    FROM security.roles
    WHERE id = p_id;

    IF v_current_status IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.role.not-found';
    END IF;

    IF v_current_status = 1 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.role.restore.not-deleted';
    END IF;

    -- Protect system roles
    IF security.is_system_role(v_current_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.role.system-protected';
    END IF;

    UPDATE security.roles
    SET
        status = 1,
        updated_at = NOW(),
        deleted_at = NULL,
        deleted_by = NULL
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION security.role_restore IS 'Restores a soft-deleted role.';

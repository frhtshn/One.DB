-- =============================================
-- 4. ROLE_UPDATE: Rol guncelle
-- Returns: VOID - Permission pattern
-- =============================================

DROP FUNCTION IF EXISTS security.role_update(BIGINT, VARCHAR, VARCHAR, BIGINT);

CREATE OR REPLACE FUNCTION security.role_update(
    p_id BIGINT,
    p_name VARCHAR DEFAULT NULL,
    p_description VARCHAR DEFAULT NULL,
    p_updated_by BIGINT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_current_status SMALLINT;
    v_current_code VARCHAR;
BEGIN
    -- Get current state
    SELECT status, code INTO v_current_status, v_current_code
    FROM security.roles
    WHERE id = p_id;

    IF v_current_status IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.role.not-found';
    END IF;

    IF v_current_status = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.role.deleted';
    END IF;

    -- Protect system roles
    IF security.is_system_role(v_current_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.role.system-protected';
    END IF;

    -- Update
    UPDATE security.roles
    SET
        name = COALESCE(NULLIF(TRIM(p_name), ''), name),
        description = CASE
            WHEN p_description IS NOT NULL THEN NULLIF(TRIM(p_description), '')
            ELSE description
        END,
        updated_at = NOW(),
        updated_by = COALESCE(p_updated_by, updated_by)
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION security.role_update IS 'Updates role details. System roles cannot be updated.';

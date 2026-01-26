-- ================================================================
-- PERMISSION_DELETE: Soft delete + role baglantilarini kaldir
-- Returns: TABLE(affected_roles) - etkilenen rol sayisi
-- ================================================================

DROP FUNCTION IF EXISTS security.permission_delete(BIGINT);

CREATE OR REPLACE FUNCTION security.permission_delete(
    p_id BIGINT
)
RETURNS TABLE(affected_roles INT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_status SMALLINT;
    v_affected_roles INT;
BEGIN
    -- Permission'i bul
    SELECT status
    INTO v_current_status
    FROM security.permissions
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.permission.not-found';
    END IF;

    -- Zaten silinmis mi?
    IF v_current_status = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.permission.delete.already-deleted';
    END IF;

    -- Role baglantilarini kaldir ve kac rol etkilendigini say
    WITH deleted AS (
        DELETE FROM security.role_permissions
        WHERE permission_id = p_id
        RETURNING role_id
    )
    SELECT COUNT(DISTINCT role_id)::INT INTO v_affected_roles FROM deleted;

    -- User permission override'larini da temizle
    DELETE FROM security.user_permission_overrides
    WHERE permission_id = p_id;

    -- Soft delete (status = 0)
    UPDATE security.permissions
    SET status = 0, updated_at = NOW()
    WHERE id = p_id;

    RETURN QUERY SELECT v_affected_roles;
END;
$$;

COMMENT ON FUNCTION security.permission_delete IS 'Soft deletes a permission and removes role associations. Returns affected role count.';

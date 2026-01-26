-- ================================================================
-- USER_PERMISSION_REMOVE - Override Kaldır
-- ================================================================

DROP FUNCTION IF EXISTS security.user_permission_remove(BIGINT, VARCHAR, BIGINT);

CREATE OR REPLACE FUNCTION security.user_permission_remove(
    p_user_id BIGINT,
    p_permission_code VARCHAR(100),
    p_tenant_id BIGINT DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_permission_id BIGINT;
    v_deleted_count INT;
BEGIN
    -- Permission code'u ID'ye çevir
    SELECT id INTO v_permission_id
    FROM security.permissions
    WHERE code = p_permission_code;

    IF v_permission_id IS NULL THEN
        RETURN FALSE;
    END IF;

    DELETE FROM security.user_permission_overrides
    WHERE user_id = p_user_id
      AND permission_id = v_permission_id
      AND COALESCE(tenant_id, -1) = COALESCE(p_tenant_id, -1);

    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;
    RETURN v_deleted_count > 0;
END;
$$;

COMMENT ON FUNCTION security.user_permission_remove IS 'Removes a permission override rule from a user. Does not affect role-based permissions.';

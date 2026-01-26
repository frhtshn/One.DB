-- ================================================================
-- PERMISSION_CHECK: Kullanıcının belirli bir permission'a sahip olup olmadığını kontrol et
-- ================================================================

DROP FUNCTION IF EXISTS security.permission_check(BIGINT, VARCHAR, BIGINT);

CREATE OR REPLACE FUNCTION security.permission_check(
    p_user_id BIGINT,
    p_permission_code VARCHAR(100),
    p_tenant_id BIGINT DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_has_permission BOOLEAN;
BEGIN
    -- Global rollerden kontrol et
    SELECT EXISTS (
        SELECT 1
        FROM security.user_roles ur
        JOIN security.role_permissions rp ON ur.role_id = rp.role_id
        JOIN security.permissions p ON rp.permission_id = p.id
        WHERE ur.user_id = p_user_id
        AND p.code = p_permission_code
        AND p.status = 1
    ) INTO v_has_permission;

    IF v_has_permission THEN
        RETURN TRUE;
    END IF;

    -- Tenant rollerinden kontrol et (tenant belirtilmişse)
    IF p_tenant_id IS NOT NULL THEN
        SELECT EXISTS (
            SELECT 1
            FROM security.user_tenant_roles utr
            JOIN security.role_permissions rp ON utr.role_id = rp.role_id
            JOIN security.permissions p ON rp.permission_id = p.id
            WHERE utr.user_id = p_user_id
            AND utr.tenant_id = p_tenant_id
            AND p.code = p_permission_code
            AND p.status = 1
        ) INTO v_has_permission;
    END IF;

    RETURN v_has_permission;
END;
$$;

COMMENT ON FUNCTION security.permission_check IS 'Checks if a user has a specific permission (Global or Tenant-level)';

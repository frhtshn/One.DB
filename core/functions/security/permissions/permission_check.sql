-- ================================================================
-- PERMISSION_CHECK: Kullanicinin belirli bir permission'a sahip olup olmadigini kontrol et
-- Override destegi + manage fallback
-- Unified user_roles: tenant_id IS NULL = global, tenant_id IS NOT NULL = tenant
-- Manage fallback: field scope haric, son segment 'manage' ile degistirilip kontrol edilir
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
    v_permission_id BIGINT;
    v_has_permission BOOLEAN := FALSE;
    v_is_denied BOOLEAN := FALSE;
    v_manage_code VARCHAR(100);
BEGIN
    -- Permission ID'yi al
    SELECT p.id INTO v_permission_id
    FROM security.permissions p
    WHERE p.code = p_permission_code AND p.status = 1;

    IF v_permission_id IS NULL THEN
        RETURN FALSE;
    END IF;

    -- 1. Override kontrolü (en yüksek öncelik)
    -- Önce deny override var mı?
    SELECT EXISTS (
        SELECT 1 FROM security.user_permission_overrides upo
        WHERE upo.user_id = p_user_id
          AND upo.permission_id = v_permission_id
          AND upo.is_granted = FALSE
          AND (upo.tenant_id IS NULL OR upo.tenant_id = p_tenant_id)
          AND (upo.expires_at IS NULL OR upo.expires_at > NOW())
    ) INTO v_is_denied;

    IF v_is_denied THEN
        RETURN FALSE;  -- Explicitly denied
    END IF;

    -- Grant override var mı?
    SELECT EXISTS (
        SELECT 1 FROM security.user_permission_overrides upo
        WHERE upo.user_id = p_user_id
          AND upo.permission_id = v_permission_id
          AND upo.is_granted = TRUE
          AND (upo.tenant_id IS NULL OR upo.tenant_id = p_tenant_id)
          AND (upo.expires_at IS NULL OR upo.expires_at > NOW())
    ) INTO v_has_permission;

    IF v_has_permission THEN
        RETURN TRUE;  -- Explicitly granted
    END IF;

    -- 2. Global rollerden kontrol et (tenant_id IS NULL)
    SELECT EXISTS (
        SELECT 1
        FROM security.user_roles ur
        JOIN security.roles r ON ur.role_id = r.id AND r.status = 1
        JOIN security.role_permissions rp ON ur.role_id = rp.role_id
        WHERE ur.user_id = p_user_id
          AND ur.tenant_id IS NULL
          AND rp.permission_id = v_permission_id
    ) INTO v_has_permission;

    IF v_has_permission THEN
        RETURN TRUE;
    END IF;

    -- 3. Tenant rollerinden kontrol et (tenant belirtilmişse, tenant_id IS NOT NULL)
    IF p_tenant_id IS NOT NULL THEN
        SELECT EXISTS (
            SELECT 1
            FROM security.user_roles ur
            JOIN security.roles r ON ur.role_id = r.id AND r.status = 1
            JOIN security.role_permissions rp ON ur.role_id = rp.role_id
            WHERE ur.user_id = p_user_id
              AND ur.tenant_id = p_tenant_id
              AND rp.permission_id = v_permission_id
        ) INTO v_has_permission;
    END IF;

    -- 4. Manage fallback (field scope'unda calismaz — waterfall kullanilir)
    IF NOT v_has_permission AND LEFT(p_permission_code, 6) != 'field.' THEN
        v_manage_code := regexp_replace(p_permission_code, '\.[^.]+$', '.manage');
        IF v_manage_code != p_permission_code THEN
            RETURN security.permission_check(p_user_id, v_manage_code, p_tenant_id);
        END IF;
    END IF;

    RETURN v_has_permission;
END;
$$;

COMMENT ON FUNCTION security.permission_check IS
'Checks if a user has a specific permission.
Priority: 1) Deny override (blocks), 2) Grant override, 3) Global roles (tenant_id IS NULL), 4) Tenant roles (tenant_id = value).
Manage fallback: If specific permission not found, checks {scope}.{entity}.manage (field scope haric).';

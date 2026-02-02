-- ================================================================
-- USER_PERMISSION_LIST: Kullanıcının tüm permission'larını döner
-- Hybrid Permission Formülü: Final = (Role Permissions + Granted) - Denied
-- Birleşik user_roles: tenant_id IS NULL = global, tenant_id IS NOT NULL = tenant
-- ================================================================

DROP FUNCTION IF EXISTS security.user_permission_list(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.user_permission_list(
    p_user_id BIGINT,
    p_tenant_id BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
    v_global_roles TEXT[];
    v_tenant_roles JSONB;
    v_role_permissions TEXT[];
    v_granted_overrides TEXT[];
    v_denied_overrides TEXT[];
    v_final_permissions TEXT[];
    v_user_record RECORD;
    v_accessible_tenant_ids BIGINT[];
    v_has_platform_role BOOLEAN := FALSE;
BEGIN
    -- Kullanıcı bilgilerini al
    SELECT id, company_id
    INTO v_user_record
    FROM security.users
    WHERE id = p_user_id AND status = 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- Global rolleri al (tenant_id IS NULL)
    SELECT ARRAY_AGG(DISTINCT r.code)
    INTO v_global_roles
    FROM security.user_roles ur
    JOIN security.roles r ON ur.role_id = r.id AND r.status = 1
    WHERE ur.user_id = p_user_id AND ur.tenant_id IS NULL;

    -- Platform role kontrolü: Global rollerden herhangi birinin is_platform_role = true olup olmadığı
    SELECT EXISTS (
        SELECT 1
        FROM security.user_roles ur
        JOIN security.roles r ON ur.role_id = r.id AND r.status = 1
        WHERE ur.user_id = p_user_id AND ur.tenant_id IS NULL AND r.is_platform_role = TRUE
    )
    INTO v_has_platform_role;

    -- Tenant bazlı rolleri ve accessible tenant ID'lerini tek sorguda al (tenant_id IS NOT NULL)
    WITH tenant_role_data AS (
        SELECT
            ur.tenant_id,
            ARRAY_AGG(DISTINCT r.code) as roles
        FROM security.user_roles ur
        JOIN security.roles r ON ur.role_id = r.id AND r.status = 1
        WHERE ur.user_id = p_user_id AND ur.tenant_id IS NOT NULL
        GROUP BY ur.tenant_id
    )
    SELECT
        COALESCE(jsonb_object_agg(tenant_id::text, to_jsonb(roles)), '{}'::jsonb),
        COALESCE(ARRAY_AGG(tenant_id), '{}')
    INTO v_tenant_roles, v_accessible_tenant_ids
    FROM tenant_role_data;

    -- Role-based permission'ları al (global roller + belirtilen tenant rolleri)
    SELECT ARRAY_AGG(DISTINCT p.code)
    INTO v_role_permissions
    FROM security.permissions p
    WHERE p.status = 1
    AND p.id IN (
        -- Global rollerden gelen permission'lar (tenant_id IS NULL)
        SELECT rp.permission_id
        FROM security.role_permissions rp
        JOIN security.user_roles ur ON rp.role_id = ur.role_id
        JOIN security.roles r ON ur.role_id = r.id AND r.status = 1
        WHERE ur.user_id = p_user_id AND ur.tenant_id IS NULL

        UNION

        -- Tenant rollerinden gelen permission'lar (belirli tenant veya tümü)
        SELECT rp.permission_id
        FROM security.role_permissions rp
        JOIN security.user_roles ur ON rp.role_id = ur.role_id
        JOIN security.roles r ON ur.role_id = r.id AND r.status = 1
        WHERE ur.user_id = p_user_id
          AND ur.tenant_id IS NOT NULL
          AND (p_tenant_id IS NULL OR ur.tenant_id = p_tenant_id)
    );

    -- User-level GRANTED overrides (is_granted=true)
    SELECT ARRAY_AGG(DISTINCT p.code)
    INTO v_granted_overrides
    FROM security.user_permission_overrides up
    JOIN security.permissions p ON up.permission_id = p.id AND p.status = 1
    WHERE up.user_id = p_user_id
        AND up.is_granted = TRUE
        AND (up.tenant_id IS NULL OR up.tenant_id = p_tenant_id OR p_tenant_id IS NULL)
        AND (up.expires_at IS NULL OR up.expires_at > NOW());

    -- User-level DENIED overrides (is_granted=false)
    SELECT ARRAY_AGG(DISTINCT p.code)
    INTO v_denied_overrides
    FROM security.user_permission_overrides up
    JOIN security.permissions p ON up.permission_id = p.id AND p.status = 1
    WHERE up.user_id = p_user_id
        AND up.is_granted = FALSE
        AND (up.tenant_id IS NULL OR up.tenant_id = p_tenant_id OR p_tenant_id IS NULL)
        AND (up.expires_at IS NULL OR up.expires_at > NOW());

    -- Final permissions = (Role Permissions + Granted) - Denied
    SELECT ARRAY_AGG(DISTINCT perm)
    INTO v_final_permissions
    FROM (
        -- Role permissions
        SELECT unnest(COALESCE(v_role_permissions, '{}')) AS perm
        UNION
        -- Granted overrides
        SELECT unnest(COALESCE(v_granted_overrides, '{}'))
    ) all_perms
    WHERE perm NOT IN (SELECT unnest(COALESCE(v_denied_overrides, '{}')));

    -- Sonucu hazırla
    v_result := jsonb_build_object(
        'userId', p_user_id,
        'companyId', v_user_record.company_id,
        'globalRoles', COALESCE(to_jsonb(v_global_roles), '[]'::jsonb),
        'tenantRoles', v_tenant_roles,
        'permissions', COALESCE(to_jsonb(v_final_permissions), '[]'::jsonb),
        'grantedOverrides', COALESCE(to_jsonb(v_granted_overrides), '[]'::jsonb),
        'deniedOverrides', COALESCE(to_jsonb(v_denied_overrides), '[]'::jsonb),
        'accessibleTenantIds', COALESCE(to_jsonb(v_accessible_tenant_ids), '[]'::jsonb),
        'hasPlatformRole', v_has_platform_role
    );

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION security.user_permission_list IS 'Hybrid Permission: Returns user roles, permissions and tenant access info. Formula: (Role + Granted) - Denied. Uses unified user_roles table.';

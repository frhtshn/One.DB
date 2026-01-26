-- ================================================================
-- USER_PERMISSION_LIST: Kullanıcının tüm permission'larını döner
-- Hybrid Permission Formülü: Final = (Role Permissions + Granted) - Denied
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
BEGIN
    -- Kullanıcı bilgilerini al
    SELECT id, company_id
    INTO v_user_record
    FROM security.users
    WHERE id = p_user_id AND status = 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- Global rolleri al
    SELECT ARRAY_AGG(DISTINCT r.code)
    INTO v_global_roles
    FROM security.user_roles ur
    JOIN security.roles r ON ur.role_id = r.id AND r.status = 1
    WHERE ur.user_id = p_user_id;

    -- Tenant bazlı rolleri al (tüm tenant'lar için)
    SELECT COALESCE(
        jsonb_object_agg(
            tenant_id::text,
            roles
        ),
        '{}'::jsonb
    )
    INTO v_tenant_roles
    FROM (
        SELECT
            utr.tenant_id,
            jsonb_agg(DISTINCT r.code) as roles
        FROM security.user_tenant_roles utr
        JOIN security.roles r ON utr.role_id = r.id AND r.status = 1
        WHERE utr.user_id = p_user_id
        GROUP BY utr.tenant_id
    ) t;

    -- Role-based permission'ları al (global roller + belirtilen tenant rolleri)
    SELECT ARRAY_AGG(DISTINCT p.code)
    INTO v_role_permissions
    FROM security.permissions p
    WHERE p.status = 1
    AND p.id IN (
        -- Global rollerden gelen permission'lar
        SELECT rp.permission_id
        FROM security.role_permissions rp
        JOIN security.user_roles ur ON rp.role_id = ur.role_id
        WHERE ur.user_id = p_user_id

        UNION

        -- Tenant rollerinden gelen permission'lar (belirli tenant veya tümü)
        SELECT rp.permission_id
        FROM security.role_permissions rp
        JOIN security.user_tenant_roles utr ON rp.role_id = utr.role_id
        WHERE utr.user_id = p_user_id
        AND (p_tenant_id IS NULL OR utr.tenant_id = p_tenant_id)
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
        'deniedOverrides', COALESCE(to_jsonb(v_denied_overrides), '[]'::jsonb)
    );

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION security.user_permission_list IS 'Hybrid Permission: Returns user roles and user-level override permissions. Formula: (Role + Granted) - Denied';

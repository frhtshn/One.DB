-- ================================================================
-- USER_AUTHENTICATE: Email ile kullanıcı doğrulama
-- ================================================================
-- Birleşik user_roles tablosu:
--   tenant_id IS NULL: Global roller (platform + company)
--   tenant_id IS NOT NULL: Tenant-specific roller
-- Scope belirleme (hardcoded rol yok):
--   Platform: user_roles WHERE tenant_id IS NULL AND is_platform_role = TRUE
--   Company:  user_roles WHERE tenant_id IS NULL AND is_platform_role = FALSE
--   Tenant:   user_roles WHERE tenant_id IS NOT NULL
-- ================================================================

DROP FUNCTION IF EXISTS security.user_authenticate(VARCHAR);

CREATE OR REPLACE FUNCTION security.user_authenticate(
    p_email VARCHAR(255)
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_user RECORD;
    v_is_platform_role BOOLEAN := FALSE;
    v_is_company_role BOOLEAN := FALSE;
    v_has_allowed_tenants BOOLEAN := FALSE;
    v_accessible_tenants JSONB := '[]'::jsonb;
    v_tenant_permissions JSONB := '{}'::jsonb;
    v_platform_roles TEXT[] := '{}';
    v_company_roles TEXT[] := '{}';
    v_global_permissions JSONB := '[]'::jsonb;
    v_company_role_permissions TEXT[] := '{}';
    v_password_expiry_days INT := 0;
    v_require_password_change BOOLEAN := FALSE;
    v_primary_department JSONB := NULL;
BEGIN
    -- ================================================================
    -- 1. KULLANICI DOGRULAMA
    -- ================================================================
    SELECT
        id, company_id, username, email, password,
        first_name, last_name, status, failed_login_count,
        is_locked, locked_until, last_login_at,
        password_changed_at, require_password_change,
        language, timezone, currency, country, two_factor_enabled
    INTO v_user
    FROM security.users
    WHERE email = p_email;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0401', MESSAGE = 'error.auth.login.invalid-credentials';
    END IF;

    IF v_user.is_locked AND (v_user.locked_until IS NULL OR v_user.locked_until > NOW()) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0423', MESSAGE = 'error.auth.login.account-locked';
    END IF;

    IF v_user.status != 1 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.auth.account-inactive';
    END IF;

    -- ================================================================
    -- 2. SIFRE DEGISIKLIK KONTROLU
    -- ================================================================
    -- Company password policy'den expiry_days al (yoksa platform default: 30)
    SELECT COALESCE(
        (SELECT cpp.expiry_days FROM security.company_password_policy cpp WHERE cpp.company_id = v_user.company_id),
        30
    ) INTO v_password_expiry_days;

    -- Şifre değişikliği gerekli mi?
    v_require_password_change := COALESCE(v_user.require_password_change, FALSE)
        OR v_user.password_changed_at IS NULL
        OR (v_password_expiry_days > 0
            AND v_user.password_changed_at + (v_password_expiry_days || ' days')::INTERVAL < NOW());

    -- ================================================================
    -- 3. GLOBAL ROLLER VE SCOPE (tek sorgu - tenant_id IS NULL)
    -- ================================================================
    SELECT
        COALESCE(ARRAY_AGG(DISTINCT r.code) FILTER (WHERE r.is_platform_role), '{}'),
        COALESCE(ARRAY_AGG(DISTINCT r.code) FILTER (WHERE NOT r.is_platform_role), '{}')
    INTO v_platform_roles, v_company_roles
    FROM security.user_roles ur
    JOIN security.roles r ON ur.role_id = r.id AND r.status = 1
    WHERE ur.user_id = v_user.id AND ur.tenant_id IS NULL;

    v_is_platform_role := array_length(v_platform_roles, 1) > 0;
    v_is_company_role := array_length(v_company_roles, 1) > 0;

    -- ================================================================
    -- 4. PLATFORM PERMISSION'LARI
    -- ================================================================
    IF v_is_platform_role THEN
        SELECT COALESCE(jsonb_agg(DISTINCT p.code), '[]'::jsonb)
        INTO v_global_permissions
        FROM security.role_permissions rp
        JOIN security.permissions p ON rp.permission_id = p.id AND p.status = 1
        JOIN security.roles r ON rp.role_id = r.id
        WHERE r.code = ANY(v_platform_roles);
    END IF;

    -- ================================================================
    -- 5. ALLOWED TENANTS KONTROLU
    -- ================================================================
    v_has_allowed_tenants := EXISTS (
        SELECT 1 FROM security.user_allowed_tenants WHERE user_id = v_user.id
    );

    -- ================================================================
    -- 6. PRIMARY DEPARTMAN
    -- ================================================================
    SELECT jsonb_build_object(
        'departmentId', d.id,
        'departmentCode', d.code,
        'departmentName', d.name
    )
    INTO v_primary_department
    FROM core.user_departments ud
    JOIN core.departments d ON d.id = ud.department_id
    WHERE ud.user_id = v_user.id AND ud.is_primary = TRUE;

    -- ================================================================
    -- 7. SCOPE BAZLI ISLEM
    -- ================================================================

    IF v_user.company_id = 0 AND v_is_platform_role THEN
        -- ============================================================
        -- PLATFORM ROLE: Tenant isi yok, sadece global permission
        -- ============================================================
        NULL; -- v_accessible_tenants ve v_tenant_permissions zaten bos

    ELSIF v_is_company_role THEN
        -- ============================================================
        -- COMPANY (companyadmin vb.): Kendi sirketinin tenant'lari
        -- ============================================================

        -- Tenant listesi
        SELECT COALESCE(jsonb_agg(
            jsonb_build_object(
                'id', t.id,
                'code', t.tenant_code,
                'name', t.tenant_name,
                'environment', t.environment
            ) ORDER BY t.id
        ), '[]'::jsonb)
        INTO v_accessible_tenants
        FROM core.tenants t
        WHERE t.company_id = v_user.company_id AND t.status = 1
          AND COALESCE(t.provisioning_status, 'draft') != 'decommissioned';

        -- Company role permission'lari (onceden hesapla)
        SELECT COALESCE(ARRAY_AGG(DISTINCT p.code), '{}')
        INTO v_company_role_permissions
        FROM security.role_permissions rp
        JOIN security.permissions p ON rp.permission_id = p.id AND p.status = 1
        JOIN security.roles r ON rp.role_id = r.id
        WHERE r.code = ANY(v_company_roles);

        -- Her tenant icin: base + granted - denied
        SELECT COALESCE(jsonb_object_agg(
            t.id::text,
            jsonb_build_object(
                'roles', to_jsonb(v_company_roles),
                'permissions', (
                    SELECT COALESCE(jsonb_agg(DISTINCT perm), '[]'::jsonb)
                    FROM (
                        SELECT unnest(v_company_role_permissions) as perm
                        UNION
                        SELECT p.code
                        FROM security.user_permission_overrides up
                        JOIN security.permissions p ON up.permission_id = p.id AND p.status = 1
                        WHERE up.user_id = v_user.id
                          AND up.is_granted = TRUE
                          AND (up.tenant_id IS NULL OR up.tenant_id = t.id)
                          AND (up.expires_at IS NULL OR up.expires_at > NOW())
                    ) base_perms
                    WHERE perm NOT IN (
                        SELECT p.code
                        FROM security.user_permission_overrides up
                        JOIN security.permissions p ON up.permission_id = p.id
                        WHERE up.user_id = v_user.id
                          AND up.is_granted = FALSE
                          AND (up.tenant_id IS NULL OR up.tenant_id = t.id)
                          AND (up.expires_at IS NULL OR up.expires_at > NOW())
                    )
                )
            )
        ), '{}'::jsonb)
        INTO v_tenant_permissions
        FROM core.tenants t
        WHERE t.company_id = v_user.company_id AND t.status = 1
          AND COALESCE(t.provisioning_status, 'draft') != 'decommissioned';

    ELSE
        -- ============================================================
        -- TENANT (tenantadmin, moderator vb.): Atanmis tenant'lar
        -- user_roles WHERE tenant_id IS NOT NULL
        -- ============================================================

        -- Tenant listesi
        SELECT COALESCE(jsonb_agg(
            jsonb_build_object(
                'id', t.id,
                'code', t.tenant_code,
                'name', t.tenant_name,
                'environment', t.environment
            ) ORDER BY t.id
        ), '[]'::jsonb)
        INTO v_accessible_tenants
        FROM (
            SELECT DISTINCT t.id, t.tenant_code, t.tenant_name, t.environment
            FROM security.user_roles ur
            JOIN core.tenants t ON ur.tenant_id = t.id AND t.status = 1
                AND COALESCE(t.provisioning_status, 'draft') != 'decommissioned'
            WHERE ur.user_id = v_user.id AND ur.tenant_id IS NOT NULL
        ) t;

        -- Her tenant icin: roller + base + granted - denied
        SELECT COALESCE(jsonb_object_agg(
            tenant_id::text,
            jsonb_build_object('roles', roles, 'permissions', permissions)
        ), '{}'::jsonb)
        INTO v_tenant_permissions
        FROM (
            SELECT
                ur.tenant_id,
                jsonb_agg(DISTINCT r.code) as roles,
                (
                    SELECT COALESCE(jsonb_agg(DISTINCT perm), '[]'::jsonb)
                    FROM (
                        -- Role permission'lari
                        SELECT p.code as perm
                        FROM security.role_permissions rp
                        JOIN security.permissions p ON rp.permission_id = p.id AND p.status = 1
                        WHERE rp.role_id IN (
                            SELECT role_id FROM security.user_roles
                            WHERE user_id = v_user.id AND tenant_id = ur.tenant_id
                        )
                        UNION
                        -- Granted override'lar
                        SELECT p.code
                        FROM security.user_permission_overrides up
                        JOIN security.permissions p ON up.permission_id = p.id AND p.status = 1
                        WHERE up.user_id = v_user.id
                          AND up.is_granted = TRUE
                          AND (up.tenant_id IS NULL OR up.tenant_id = ur.tenant_id)
                          AND (up.expires_at IS NULL OR up.expires_at > NOW())
                    ) base_perms
                    WHERE perm NOT IN (
                        -- Denied override'lar
                        SELECT p.code
                        FROM security.user_permission_overrides up
                        JOIN security.permissions p ON up.permission_id = p.id
                        WHERE up.user_id = v_user.id
                          AND up.is_granted = FALSE
                          AND (up.tenant_id IS NULL OR up.tenant_id = ur.tenant_id)
                          AND (up.expires_at IS NULL OR up.expires_at > NOW())
                    )
                ) as permissions
            FROM security.user_roles ur
            JOIN security.roles r ON ur.role_id = r.id AND r.status = 1
            WHERE ur.user_id = v_user.id AND ur.tenant_id IS NOT NULL
            GROUP BY ur.tenant_id
        ) t;

    END IF;

    -- ================================================================
    -- 8. RESPONSE
    -- ================================================================
    RETURN jsonb_build_object(
        'user', jsonb_build_object(
            'id', v_user.id,
            'companyId', v_user.company_id,
            'username', v_user.username,
            'email', v_user.email,
            'passwordHash', v_user.password,
            'firstName', v_user.first_name,
            'lastName', v_user.last_name,
            'failedLoginCount', v_user.failed_login_count,
            'lastLoginAt', v_user.last_login_at,
            'passwordChangedAt', v_user.password_changed_at,
            'requirePasswordChange', v_require_password_change,
            'language', v_user.language,
            'timezone', v_user.timezone,
            'currency', v_user.currency,
            'country', v_user.country,
            'primaryDepartment', v_primary_department,
            'twoFactorEnabled', v_user.two_factor_enabled
        ),
        'globalRoles', to_jsonb(v_platform_roles),
        'globalPermissions', v_global_permissions,
        'accessibleTenants', v_accessible_tenants,
        'tenantPermissions', v_tenant_permissions
    );
END;
$$;

COMMENT ON FUNCTION security.user_authenticate IS
'Email ile kullanici dogrulama. Unified user_roles tablosu: tenant_id=NULL for global, tenant_id=value for tenant-specific. Includes primaryDepartment (JSONB multi-language name) and twoFactorEnabled in user object. Sifre suresi dolmussa requirePasswordChange=true doner.';

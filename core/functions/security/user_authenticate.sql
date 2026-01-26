-- ================================================================
-- USER_AUTHENTICATE: Email ile kullanıcı doğrulama
-- Email unique olduğu için CompanyId gerekmez
-- Platform rolleri için globalPermissions, diğer roller için tenantPermissions döner
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
    v_is_company_admin BOOLEAN;
    v_is_platform_role BOOLEAN;
    v_has_allowed_tenants BOOLEAN;
    v_accessible_tenants JSONB;
    v_tenant_permissions JSONB;
    v_global_roles_for_check TEXT[];  -- Ic kullanim: company_admin kontrolu
    v_platform_roles TEXT[];          -- Response: sadece platform rolleri
    v_global_permissions JSONB;       -- Response: platform rol permission'lari
BEGIN
    -- Kullaniciyi bul (sadece email ile - email unique)
    SELECT
        id,
        company_id,
        username,
        email,
        password,
        first_name,
        last_name,
        status,
        failed_login_count,
        is_locked,
        locked_until,
        last_login_at,
        language
    INTO v_user
    FROM security.users
    WHERE email = p_email;

    -- Kullanici bulunamadi
    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0401', MESSAGE = 'error.auth.invalid-credentials';
    END IF;

    -- Hesap kilitli mi?
    IF v_user.is_locked AND (v_user.locked_until IS NULL OR v_user.locked_until > NOW()) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0423', MESSAGE = 'error.auth.account-locked';
    END IF;

    -- Hesap aktif degilse
    IF v_user.status != 1 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.auth.account-inactive';
    END IF;

    -- TUM global rolleri al (ic kullanim icin - company_admin kontrolu)
    SELECT ARRAY_AGG(DISTINCT r.code)
    INTO v_global_roles_for_check
    FROM security.user_roles ur
    JOIN security.roles r ON ur.role_id = r.id AND r.status = 1
    WHERE ur.user_id = v_user.id;

    v_global_roles_for_check := COALESCE(v_global_roles_for_check, '{}');
    v_is_company_admin := 'superadmin' = ANY(v_global_roles_for_check) OR 'company_admin' = ANY(v_global_roles_for_check);

    -- SADECE platform rollerini al (response icin)
    SELECT ARRAY_AGG(DISTINCT r.code)
    INTO v_platform_roles
    FROM security.user_roles ur
    JOIN security.roles r ON ur.role_id = r.id AND r.status = 1
    WHERE ur.user_id = v_user.id
      AND r.is_platform_role = TRUE;

    v_platform_roles := COALESCE(v_platform_roles, '{}');
    v_is_platform_role := array_length(v_platform_roles, 1) > 0;

    -- Platform rolleri icin permission'lari al
    IF v_is_platform_role THEN
        SELECT COALESCE(jsonb_agg(DISTINCT p.code), '[]'::jsonb)
        INTO v_global_permissions
        FROM security.role_permissions rp
        JOIN security.permissions p ON rp.permission_id = p.id AND p.status = 1
        JOIN security.user_roles ur ON rp.role_id = ur.role_id
        JOIN security.roles r ON ur.role_id = r.id
        WHERE ur.user_id = v_user.id
          AND r.is_platform_role = TRUE;
    ELSE
        v_global_permissions := '[]'::jsonb;
    END IF;

    -- user_allowed_tenants tablosunda kayit var mi?
    SELECT EXISTS (
        SELECT 1 FROM security.user_allowed_tenants WHERE user_id = v_user.id
    ) INTO v_has_allowed_tenants;

    -- Erisilebilir tenant'lari al
    IF v_user.company_id = 0 AND 'superadmin' = ANY(v_platform_roles) THEN
        -- SuperAdmin: tenant isi yok, bos don
        v_accessible_tenants := '[]'::jsonb;
        v_tenant_permissions := '{}'::jsonb;

    ELSIF v_is_platform_role THEN
        -- Admin (platform yoneticisi)
        IF v_has_allowed_tenants THEN
            -- Kisitli erisim: sadece izin verilen tenant'lar
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
            JOIN security.user_allowed_tenants uat ON t.id = uat.tenant_id
            WHERE uat.user_id = v_user.id
              AND t.status = 1;
        ELSE
            -- Tam erisim: tum tenant'lar (user_allowed_tenants bos ise)
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
            WHERE t.status = 1;
        END IF;

        -- Platform rolleri icin tenantPermissions BOS
        v_tenant_permissions := '{}'::jsonb;

    ELSIF v_is_company_admin THEN
        -- Company admin: sirketin tum tenant'larina erisir
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
        WHERE t.company_id = v_user.company_id AND t.status = 1;

        -- Company admin: tum tenant'larda tum permission'lara sahip
        SELECT COALESCE(jsonb_object_agg(
            t.id::text,
            jsonb_build_object(
                'roles', to_jsonb(ARRAY['company_admin']),
                'permissions', (
                    SELECT COALESCE(jsonb_agg(p.code), '[]'::jsonb)
                    FROM security.permissions p
                    WHERE p.status = 1
                      AND p.code NOT IN (
                          SELECT p2.code
                          FROM security.user_permission_overrides up
                          JOIN security.permissions p2 ON up.permission_id = p2.id
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
        WHERE t.company_id = v_user.company_id AND t.status = 1;

    ELSE
        -- Normal kullanici: sadece user_tenant_roles'da tanimli tenant'lar
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
            FROM security.user_tenant_roles utr
            JOIN core.tenants t ON utr.tenant_id = t.id AND t.status = 1
            WHERE utr.user_id = v_user.id
        ) t;

        -- Normal kullanici: her tenant icin ayri hesapla
        SELECT COALESCE(jsonb_object_agg(
            tenant_id::text,
            jsonb_build_object(
                'roles', roles,
                'permissions', final_permissions
            )
        ), '{}'::jsonb)
        INTO v_tenant_permissions
        FROM (
            SELECT
                utr.tenant_id,
                jsonb_agg(DISTINCT r.code) as roles,
                (
                    SELECT COALESCE(jsonb_agg(DISTINCT perm), '[]'::jsonb)
                    FROM (
                        SELECT p.code as perm
                        FROM security.role_permissions rp
                        JOIN security.permissions p ON rp.permission_id = p.id AND p.status = 1
                        WHERE rp.role_id IN (
                            SELECT utr2.role_id
                            FROM security.user_tenant_roles utr2
                            WHERE utr2.user_id = v_user.id AND utr2.tenant_id = utr.tenant_id
                        )
                        UNION
                        SELECT p.code as perm
                        FROM security.user_permission_overrides up
                        JOIN security.permissions p ON up.permission_id = p.id AND p.status = 1
                        WHERE up.user_id = v_user.id
                          AND up.is_granted = TRUE
                          AND (up.tenant_id IS NULL OR up.tenant_id = utr.tenant_id)
                          AND (up.expires_at IS NULL OR up.expires_at > NOW())
                    ) all_perms
                    WHERE perm NOT IN (
                        SELECT p.code
                        FROM security.user_permission_overrides up
                        JOIN security.permissions p ON up.permission_id = p.id
                        WHERE up.user_id = v_user.id
                          AND up.is_granted = FALSE
                          AND (up.tenant_id IS NULL OR up.tenant_id = utr.tenant_id)
                          AND (up.expires_at IS NULL OR up.expires_at > NOW())
                    )
                ) as final_permissions
            FROM security.user_tenant_roles utr
            JOIN security.roles r ON utr.role_id = r.id AND r.status = 1
            WHERE utr.user_id = v_user.id
            GROUP BY utr.tenant_id
        ) t;
    END IF;

    -- Basarili sonuc dondur
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
            'language', v_user.language
        ),
        'globalRoles', COALESCE(to_jsonb(v_platform_roles), '[]'::jsonb),
        'globalPermissions', v_global_permissions,
        'accessibleTenants', v_accessible_tenants,
        'tenantPermissions', v_tenant_permissions
    );
END;
$$;

COMMENT ON FUNCTION security.user_authenticate IS 'Authenticates user via email. Returns structured user data, roles, and permissions based on role type (Platform vs Company/Tenant).';

-- ================================================================
-- USER_GET: Kullanıcı detayı (IDOR Korumalı)
-- ================================================================
-- Erişim Kuralları:
--   - Platform Admin (SuperAdmin/Admin): Herkesi görebilir
--   - CompanyAdmin: Kendi şirketindeki kullanıcıları görebilir
--   - TenantAdmin: Kendi tenant'ındaki kullanıcıları görebilir
--                  (sadece o tenant'taki rolleri görür)
--   - Diğerleri: ERİŞİM YOK
-- Güvenlik:
--   - Kilitli caller erişemez
--   - Silinmiş/pasif hedef döndürülmez
-- ================================================================

DROP FUNCTION IF EXISTS security.user_get(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.user_get(
    p_caller_id BIGINT,
    p_user_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = security, core, pg_temp
AS $$
DECLARE
    v_result JSONB;
    v_caller_company_id BIGINT;
    v_caller_has_platform_role BOOLEAN;
    v_caller_is_company_admin BOOLEAN;
    v_caller_tenant_ids BIGINT[];
    v_target_company_id BIGINT;
    v_target_status SMALLINT;
    v_target_has_role_in_caller_tenant BOOLEAN;
    v_visible_tenant_ids BIGINT[];
BEGIN
    -- ========================================
    -- 1. CALLER BİLGİLERİNİ AL
    -- ========================================
    SELECT
        u.company_id,
        EXISTS(
            SELECT 1 FROM security.user_roles ur2
            JOIN security.roles r2 ON ur2.role_id = r2.id AND r2.status = 1
            WHERE ur2.user_id = u.id AND ur2.tenant_id IS NULL AND r2.is_platform_role = TRUE
        ),
        EXISTS(
            SELECT 1 FROM security.user_roles ur2
            JOIN security.roles r2 ON ur2.role_id = r2.id AND r2.status = 1
            WHERE ur2.user_id = u.id AND ur2.tenant_id IS NULL AND r2.code = 'companyadmin'
        )
    INTO v_caller_company_id, v_caller_has_platform_role, v_caller_is_company_admin
    FROM security.users u
    WHERE u.id = p_caller_id
      AND u.status = 1
      AND u.is_locked = FALSE
      AND (u.locked_until IS NULL OR u.locked_until < NOW());

    IF v_caller_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

    -- Caller'ın TenantAdmin olduğu tenant'ları al (aktif roller)
    SELECT ARRAY_AGG(DISTINCT ur.tenant_id)
    INTO v_caller_tenant_ids
    FROM security.user_roles ur
    JOIN security.roles r ON ur.role_id = r.id AND r.status = 1
    WHERE ur.user_id = p_caller_id
      AND ur.tenant_id IS NOT NULL
      AND r.code = 'tenantadmin';

    -- ========================================
    -- 2. TARGET KULLANICI VARLIK KONTROLÜ
    -- ========================================
    SELECT u.company_id, u.status
    INTO v_target_company_id, v_target_status
    FROM security.users u
    WHERE u.id = p_user_id;

    IF v_target_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- Silinmiş/pasif kullanıcı
    IF v_target_status != 1 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- ========================================
    -- 3. IDOR KONTROLÜ (Scope)
    -- ========================================
    IF NOT v_caller_has_platform_role THEN
        -- Aynı şirkette olmalı
        IF v_target_company_id != v_caller_company_id THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
        END IF;

        -- CompanyAdmin değilse TenantAdmin kontrolü
        IF NOT v_caller_is_company_admin THEN
            -- TenantAdmin değilse (tenant_ids NULL) erişemez
            IF v_caller_tenant_ids IS NULL THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.denied';
            END IF;

            -- TenantAdmin scope kontrolü (aktif roller)
            SELECT EXISTS(
                SELECT 1 FROM security.user_roles ur
                JOIN security.roles r ON ur.role_id = r.id AND r.status = 1
                WHERE ur.user_id = p_user_id
                  AND ur.tenant_id = ANY(v_caller_tenant_ids)
            ) INTO v_target_has_role_in_caller_tenant;

            IF NOT v_target_has_role_in_caller_tenant THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.tenant-scope-denied';
            END IF;
        END IF;
    END IF;

    -- ========================================
    -- 4. GÖRÜNÜR TENANT'LARI BELİRLE
    -- ========================================
    -- Platform Admin veya CompanyAdmin: Tüm tenant'ları görür
    -- TenantAdmin: Sadece kendi tenant'larını görür
    IF v_caller_has_platform_role OR v_caller_is_company_admin THEN
        v_visible_tenant_ids := NULL; -- NULL = tümü
    ELSE
        v_visible_tenant_ids := v_caller_tenant_ids;
    END IF;

    -- ========================================
    -- 5. KULLANICI BİLGİLERİNİ GETİR
    -- ========================================
    SELECT jsonb_build_object(
        'id', u.id,
        'email', u.email,
        'username', u.username,
        'firstName', u.first_name,
        'lastName', u.last_name,
        'fullName', u.first_name || ' ' || u.last_name,
        'status', u.status,
        'isActive', (u.status = 1),
        'isLocked', u.is_locked,
        'lockedUntil', u.locked_until,
        'failedLoginCount', u.failed_login_count,
        'twoFactorEnabled', u.two_factor_enabled,
        'language', u.language,
        'timezone', u.timezone,
        'currency', u.currency,
        'lastLoginAt', u.last_login_at,
        'passwordChangedAt', u.password_changed_at,
        'requirePasswordChange', u.require_password_change,
        'createdAt', u.created_at,
        'updatedAt', u.updated_at,
        'companyId', u.company_id,
        'companyName', c.company_name,
        -- Kullanıcının departmanları
        'departments', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'departmentId', d.id,
                'departmentCode', d.code,
                'departmentName', d.name,
                'parentId', d.parent_id,
                'parentName', pd.name,
                'isPrimary', ud.is_primary,
                'assignedAt', ud.assigned_at
            ) ORDER BY ud.is_primary DESC, d.code)
            FROM core.user_departments ud
            JOIN core.departments d ON d.id = ud.department_id
            LEFT JOIN core.departments pd ON pd.id = d.parent_id
            WHERE ud.user_id = u.id
        ), '[]'::jsonb),
        -- Platform Admin ve CompanyAdmin global rolleri görür
        'globalRoles', CASE
            WHEN v_caller_has_platform_role OR v_caller_is_company_admin THEN
                COALESCE((
                    SELECT jsonb_agg(jsonb_build_object(
                        'roleId', r.id,
                        'roleCode', r.code,
                        'roleName', r.name
                    ) ORDER BY r.id)
                    FROM security.user_roles ur
                    JOIN security.roles r ON r.id = ur.role_id AND r.status = 1
                    WHERE ur.user_id = u.id AND ur.tenant_id IS NULL
                ), '[]'::jsonb)
            ELSE '[]'::jsonb
        END,
        -- Tenant rolleri (filtrelenmiş, aktif roller)
        'tenantRoles', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'tenantId', ur.tenant_id,
                'tenantName', t.tenant_name,
                'roleId', r.id,
                'roleCode', r.code,
                'roleName', r.name
            ) ORDER BY ur.tenant_id, r.id)
            FROM security.user_roles ur
            JOIN security.roles r ON r.id = ur.role_id AND r.status = 1
            JOIN core.tenants t ON t.id = ur.tenant_id
            WHERE ur.user_id = u.id
              AND ur.tenant_id IS NOT NULL
              AND (v_visible_tenant_ids IS NULL OR ur.tenant_id = ANY(v_visible_tenant_ids))
        ), '[]'::jsonb),
        -- Allowed tenants (filtrelenmiş)
        'allowedTenants', COALESCE((
            SELECT jsonb_agg(uat.tenant_id ORDER BY uat.tenant_id)
            FROM security.user_allowed_tenants uat
            WHERE uat.user_id = u.id
              AND (v_visible_tenant_ids IS NULL OR uat.tenant_id = ANY(v_visible_tenant_ids))
        ), '[]'::jsonb)
    )
    INTO v_result
    FROM security.users u
    LEFT JOIN core.companies c ON c.id = u.company_id
    WHERE u.id = p_user_id;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION security.user_get(BIGINT, BIGINT) IS
'Returns user details with IDOR protection. Includes departments (JSONB multi-language name).
Access: Platform Admin (all), CompanyAdmin (same company), TenantAdmin (own tenant users).
TenantAdmin only sees roles in their own tenant.
Locked callers and deleted targets are rejected.';

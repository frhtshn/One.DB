-- =============================================
-- USER_ROLE_ASSIGN: Kullanıcıya rol ata (IDOR + Privilege + Hiyerarşi Korumalı)
-- =============================================
-- Unified user_roles: tenant_id = NULL for global, tenant_id = değer for tenant
-- Erişim:
--   - Platform Admin (SuperAdmin/Admin): Global rol atayabilir
--   - SuperAdmin: admin + companyadmin atayabilir
--   - Admin: sadece companyadmin atayabilir
--   - CompanyAdmin: tenantadmin + altı (kendi şirketinde)
--   - TenantAdmin: moderator + altı (kendi tenant'ında)
-- Kısıtlamalar:
--   - superadmin rolü atanamaz (system protected)
--   - Kendi seviyesinde veya üstünde rol atanamaz
-- Returns: TABLE(already_assigned) - idempotent bilgi
-- =============================================

DROP FUNCTION IF EXISTS security.user_role_assign(BIGINT, BIGINT, VARCHAR, BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.user_role_assign(
    p_caller_id BIGINT,
    p_user_id BIGINT,
    p_role_code VARCHAR,
    p_tenant_id BIGINT DEFAULT NULL,
    p_assigned_by BIGINT DEFAULT NULL
)
RETURNS TABLE(already_assigned BOOLEAN)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_caller_company_id BIGINT;
    v_caller_level INT;
    v_caller_is_platform_admin BOOLEAN;
    v_caller_is_superadmin BOOLEAN;
    v_target_company_id BIGINT;
    v_target_level INT;
    v_tenant_company_id BIGINT;
    v_role_id BIGINT;
    v_role_status SMALLINT;
    v_role_level INT;
    v_role_is_tenant_role BOOLEAN;
    v_role_code VARCHAR;
    v_already_assigned BOOLEAN;
BEGIN
    -- 1. Caller bilgisi (global + hedef tenant rolleri dikkate alınır)
    SELECT
        u.company_id,
        COALESCE(MAX(r.level), 0),
        EXISTS(
            SELECT 1 FROM security.user_roles ur2
            JOIN security.roles r2 ON ur2.role_id = r2.id
            WHERE ur2.user_id = u.id AND ur2.tenant_id IS NULL AND r2.is_platform_role = TRUE
        ),
        EXISTS(
            SELECT 1 FROM security.user_roles ur2
            JOIN security.roles r2 ON ur2.role_id = r2.id
            WHERE ur2.user_id = u.id AND ur2.tenant_id IS NULL AND r2.code = 'superadmin'
        )
    INTO v_caller_company_id, v_caller_level, v_caller_is_platform_admin, v_caller_is_superadmin
    FROM security.users u
    LEFT JOIN security.user_roles ur ON ur.user_id = u.id
        AND (ur.tenant_id IS NULL OR ur.tenant_id = p_tenant_id)
    LEFT JOIN security.roles r ON r.id = ur.role_id AND r.status = 1
    WHERE u.id = p_caller_id AND u.status = 1
    GROUP BY u.id, u.company_id;

    IF v_caller_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

    -- 2. Target user bilgisi
    SELECT
        u.company_id,
        COALESCE(MAX(r.level), 0)
    INTO v_target_company_id, v_target_level
    FROM security.users u
    LEFT JOIN security.user_roles ur ON ur.user_id = u.id AND ur.tenant_id IS NULL
    LEFT JOIN security.roles r ON r.id = ur.role_id AND r.status = 1
    WHERE u.id = p_user_id AND u.status = 1
    GROUP BY u.id, u.company_id;

    IF v_target_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- 3. Normalize role code
    v_role_code := LOWER(TRIM(p_role_code));

    -- 4. System rol koruması (superadmin atanamaz)
    IF security.is_system_role(v_role_code) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.role.system-protected';
    END IF;

    -- 5. Rol bilgisi
    SELECT id, status, level, NOT is_platform_role
    INTO v_role_id, v_role_status, v_role_level, v_role_is_tenant_role
    FROM security.roles
    WHERE code = v_role_code;

    IF v_role_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.role.not-found';
    END IF;

    IF v_role_status = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.role.inactive';
    END IF;

    -- 6. Rol tipi ve tenant_id uyumluluk kontrolü
    IF v_role_is_tenant_role AND p_tenant_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.role.tenant-required';
    END IF;

    IF NOT v_role_is_tenant_role AND p_tenant_id IS NOT NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.role.global-only';
    END IF;

    -- 7. Tenant kontrolü (varsa)
    IF p_tenant_id IS NOT NULL THEN
        SELECT company_id INTO v_tenant_company_id
        FROM core.tenants
        WHERE id = p_tenant_id AND status = 1;

        IF v_tenant_company_id IS NULL THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
        END IF;
    END IF;

    -- 8. Admin, admin rolü atayamaz (sadece SuperAdmin atayabilir)
    IF v_role_code = 'admin' AND NOT v_caller_is_superadmin THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.role.insufficient-level';
    END IF;

    -- 9. Hiyerarşi kontrolü: Caller kendi seviyesinden düşük rolleri atayabilir
    IF v_role_level >= v_caller_level THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.role.hierarchy-violation';
    END IF;

    -- 10. Hedef kullanıcı scope kontrolü (platform rolü yoksa)
    IF NOT v_caller_is_platform_admin THEN
        IF v_target_company_id != v_caller_company_id THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
        END IF;

        IF v_target_level >= v_caller_level THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.role.target-level-violation';
        END IF;

        -- Tenant ataması için tenant'ın aynı şirkette olması gerekir
        IF p_tenant_id IS NOT NULL AND v_tenant_company_id != v_caller_company_id THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.tenant-scope-denied';
        END IF;
    END IF;

    -- 11. Zaten atanmış mı?
    SELECT EXISTS(
        SELECT 1 FROM security.user_roles
        WHERE user_id = p_user_id
          AND role_id = v_role_id
          AND ((p_tenant_id IS NULL AND tenant_id IS NULL) OR (tenant_id = p_tenant_id))
    ) INTO v_already_assigned;

    -- 12. Atama yap
    IF NOT v_already_assigned THEN
        INSERT INTO security.user_roles (user_id, role_id, tenant_id, assigned_at, assigned_by)
        VALUES (p_user_id, v_role_id, p_tenant_id, NOW(), COALESCE(p_assigned_by, p_caller_id));
    END IF;

    RETURN QUERY SELECT v_already_assigned;
END;
$$;

COMMENT ON FUNCTION security.user_role_assign(BIGINT, BIGINT, VARCHAR, BIGINT, BIGINT) IS
'Assigns a role to a user. IDOR + Privilege + Hierarchy protected.
Unified user_roles: tenant_id=NULL for global, tenant_id=value for tenant.
Access: Platform Admin (global roles), CompanyAdmin (tenant roles in own company).
Hierarchy: Can only assign roles below own level.
System roles (superadmin) cannot be assigned.';

-- ================================================================
-- USER_PERMISSION_REMOVE - Override Kaldır (IDOR + Privilege Escalation korumalı)
-- ================================================================
-- Erişim:
--   Platform Admin: Her override'ı kaldırabilir
--   Company Admin: Kendi şirketindeki user'lardan, sahip olduğu permission override'larını kaldırabilir
--   Tenant Admin: Kendi tenant'ındaki user'lardan, sahip olduğu permission override'larını kaldırabilir
--   Diğerleri: Kaldıramaz
-- ================================================================

DROP FUNCTION IF EXISTS security.user_permission_remove(BIGINT, BIGINT, VARCHAR, BIGINT);

CREATE OR REPLACE FUNCTION security.user_permission_remove(
    p_caller_id BIGINT,
    p_user_id BIGINT,
    p_permission_code VARCHAR(100),
    p_tenant_id BIGINT DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_permission_id BIGINT;
    v_deleted_count INT;
    v_caller_company_id BIGINT;
    v_target_company_id BIGINT;
    v_tenant_company_id BIGINT;
    v_has_platform_role BOOLEAN;
    v_is_company_admin BOOLEAN;
    v_is_tenant_admin BOOLEAN;
BEGIN
    -- ========================================
    -- 1. TEMEL DOĞRULAMALAR
    -- ========================================

    -- Permission code'u ID'ye çevir
    SELECT p.id INTO v_permission_id
    FROM security.permissions p
    WHERE p.code = p_permission_code AND p.status = 1;

    IF v_permission_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.permission.not-found';
    END IF;

    -- Hedef user var mı?
    SELECT u.company_id FROM security.users u
    WHERE u.id = p_user_id AND u.status = 1
    INTO v_target_company_id;

    IF v_target_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- Caller var mı?
    SELECT u.company_id FROM security.users u
    WHERE u.id = p_caller_id AND u.status = 1
    INTO v_caller_company_id;

    IF v_caller_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

    -- ========================================
    -- 2. IDOR + PRIVILEGE ESCALATION KONTROLLERI
    -- ========================================

    -- Platform admin kontrolü (global roller, tenant_id IS NULL)
    SELECT EXISTS(
        SELECT 1 FROM security.user_roles ur
        JOIN security.roles r ON ur.role_id = r.id
        WHERE ur.user_id = p_caller_id AND ur.tenant_id IS NULL AND r.is_platform_role = TRUE
    ) INTO v_has_platform_role;

    IF v_has_platform_role THEN
        -- Platform admin her şeyi kaldırabilir
        NULL;
    ELSE
        -- ========================================
        -- IDOR KONTROLÜ (Scope)
        -- ========================================

        -- Aynı şirketten mi?
        IF v_target_company_id != v_caller_company_id THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.user-scope-denied';
        END IF;

        -- Company admin kontrolü (global rol, tenant_id IS NULL)
        SELECT EXISTS(
            SELECT 1 FROM security.user_roles ur
            JOIN security.roles r ON ur.role_id = r.id
            WHERE ur.user_id = p_caller_id AND ur.tenant_id IS NULL AND r.code = 'companyadmin'
        ) INTO v_is_company_admin;

        IF v_is_company_admin THEN
            -- Company admin kendi şirketindeki herkesten kaldırabilir
            IF p_tenant_id IS NOT NULL THEN
                -- Tenant şirkete ait mi?
                SELECT t.company_id FROM core.tenants t
                WHERE t.id = p_tenant_id
                INTO v_tenant_company_id;

                IF v_tenant_company_id IS NULL OR v_tenant_company_id != v_caller_company_id THEN
                    RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.tenant-scope-denied';
                END IF;
            END IF;
        ELSE
            -- Tenant admin kontrolü
            IF p_tenant_id IS NULL THEN
                RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.tenant.id-required';
            END IF;

            -- Tenant var mı ve şirkete ait mi?
            SELECT t.company_id FROM core.tenants t
            WHERE t.id = p_tenant_id
            INTO v_tenant_company_id;

            IF v_tenant_company_id IS NULL THEN
                RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
            END IF;

            IF v_tenant_company_id != v_caller_company_id THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.tenant-scope-denied';
            END IF;

            -- Caller bu tenant'ta tenant admin mi? (birleşik user_roles, tenant_id = p_tenant_id)
            SELECT EXISTS(
                SELECT 1 FROM security.user_roles ur
                JOIN security.roles r ON ur.role_id = r.id
                WHERE ur.user_id = p_caller_id
                  AND ur.tenant_id = p_tenant_id
                  AND r.code = 'tenantadmin'
            ) INTO v_is_tenant_admin;

            IF NOT v_is_tenant_admin THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.permission-denied';
            END IF;

            -- Hedef user bu tenant'a erişebiliyor mu?
            IF NOT EXISTS(
                SELECT 1 FROM security.user_allowed_tenants uat
                WHERE uat.user_id = p_user_id AND uat.tenant_id = p_tenant_id
            ) AND NOT EXISTS(
                SELECT 1 FROM security.user_roles ur
                JOIN security.roles r ON ur.role_id = r.id
                WHERE ur.user_id = p_user_id
                  AND ur.tenant_id IS NULL
                  AND r.code = 'companyadmin'
                  AND v_target_company_id = v_tenant_company_id
            ) AND NOT EXISTS(
                SELECT 1 FROM security.user_roles ur
                JOIN security.roles r ON ur.role_id = r.id
                WHERE ur.user_id = p_user_id AND ur.tenant_id IS NULL AND r.is_platform_role = TRUE
            ) THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.user-scope-denied';
            END IF;
        END IF;

        -- ========================================
        -- PRIVILEGE ESCALATION KONTROLÜ
        -- ========================================

        -- Caller bu permission'a sahip mi? (override dahil)
        IF NOT security.permission_check(p_caller_id, p_permission_code, p_tenant_id) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.auth.permission-escalation';
        END IF;
    END IF;

    -- ========================================
    -- 3. OVERRIDE KALDIRMA İŞLEMİ
    -- ========================================

    DELETE FROM security.user_permission_overrides upo
    WHERE upo.user_id = p_user_id
      AND upo.permission_id = v_permission_id
      AND COALESCE(upo.tenant_id, -1) = COALESCE(p_tenant_id, -1);

    GET DIAGNOSTICS v_deleted_count = ROW_COUNT;

    RETURN v_deleted_count > 0;
END;
$$;

COMMENT ON FUNCTION security.user_permission_remove IS
'Removes a permission override from a user (IDOR + Privilege Escalation protected).
Access: Platform Admin (all), Company Admin (same company), Tenant Admin (same tenant).
Privilege Check: Caller must have the permission to remove its override.';

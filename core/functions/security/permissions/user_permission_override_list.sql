-- ================================================================
-- USER_PERMISSION_OVERRIDE_LIST - Override Listesi (IDOR Korumalı)
-- ================================================================
-- Erişim:
--   Platform Admin: Herkes
--   Company Admin: Kendi şirketindeki user'lar
--   Tenant Admin: Kendi tenant'ındaki user'lar (p_tenant_id zorunlu)
--   Diğerleri: Erişim yok
-- ================================================================

DROP FUNCTION IF EXISTS security.user_permission_override_list(BIGINT, BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.user_permission_override_list(
    p_caller_id BIGINT,
    p_user_id BIGINT,
    p_tenant_id BIGINT DEFAULT NULL
)
RETURNS TABLE (
    permission_code VARCHAR(100),
    permission_name VARCHAR(150),
    category VARCHAR(50),
    is_granted BOOLEAN,
    tenant_id BIGINT,
    context_id BIGINT,
    reason VARCHAR(500),
    assigned_by BIGINT,
    assigned_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_caller_company_id BIGINT;
    v_target_company_id BIGINT;
    v_tenant_company_id BIGINT;
    v_has_platform_role BOOLEAN;
    v_is_company_admin BOOLEAN;
    v_is_tenant_admin BOOLEAN;
BEGIN
    -- 1. Caller bilgisi
    SELECT u.company_id FROM security.users u
    WHERE u.id = p_caller_id AND u.status = 1
    INTO v_caller_company_id;

    IF v_caller_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

    -- 2. Hedef user bilgisi
    SELECT u.company_id FROM security.users u
    WHERE u.id = p_user_id AND u.status = 1
    INTO v_target_company_id;

    IF v_target_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- 3. Platform admin kontrolü (global roller, tenant_id IS NULL)
    SELECT EXISTS(
        SELECT 1 FROM security.user_roles ur
        JOIN security.roles r ON ur.role_id = r.id
        WHERE ur.user_id = p_caller_id AND ur.tenant_id IS NULL AND r.is_platform_role = TRUE
    ) INTO v_has_platform_role;

    IF v_has_platform_role THEN
        -- Platform admin herkesi görebilir
        NULL;
    ELSE
        -- 4. Aynı şirketten mi?
        IF v_target_company_id != v_caller_company_id THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.user-scope-denied';
        END IF;

        -- 5. Company admin kontrolü (global rol, tenant_id IS NULL)
        SELECT EXISTS(
            SELECT 1 FROM security.user_roles ur
            JOIN security.roles r ON ur.role_id = r.id
            WHERE ur.user_id = p_caller_id AND ur.tenant_id IS NULL AND r.code = 'companyadmin'
        ) INTO v_is_company_admin;

        IF v_is_company_admin THEN
            -- Company admin kendi şirketindeki herkesi görebilir
            -- p_tenant_id null veya dolu olabilir
            IF p_tenant_id IS NOT NULL THEN
                -- Tenant şirkete ait mi kontrol et
                SELECT t.company_id FROM core.tenants t
                WHERE t.id = p_tenant_id
                INTO v_tenant_company_id;

                IF v_tenant_company_id IS NULL OR v_tenant_company_id != v_caller_company_id THEN
                    RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.tenant-scope-denied';
                END IF;
            END IF;
        ELSE
            -- 6. Tenant admin kontrolü
            IF p_tenant_id IS NULL THEN
                -- Tenant admin için p_tenant_id zorunlu
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
            -- 1. user_allowed_tenants'ta var mı? VEYA
            -- 2. companyadmin mı ve tenant aynı şirkette mi? VEYA
            -- 3. platform admin mı?
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
    END IF;

    -- 7. Override listesini getir
    RETURN QUERY
    SELECT
        p.code AS permission_code,
        p.name AS permission_name,
        p.category,
        up.is_granted,
        up.tenant_id,
        up.context_id,
        up.reason,
        up.assigned_by,
        up.assigned_at,
        up.expires_at
    FROM security.user_permission_overrides up
    JOIN security.permissions p ON up.permission_id = p.id
    WHERE up.user_id = p_user_id
      AND (p_tenant_id IS NULL OR up.tenant_id IS NULL OR up.tenant_id = p_tenant_id)
      AND (up.expires_at IS NULL OR up.expires_at > NOW())
    ORDER BY p.category, p.code;
END;
$$;

COMMENT ON FUNCTION security.user_permission_override_list IS
'Lists active permission overrides for a user (IDOR protected).
Access: Platform Admin (all), Company Admin (same company), Tenant Admin (same tenant, p_tenant_id required).
Normal users cannot view overrides.';

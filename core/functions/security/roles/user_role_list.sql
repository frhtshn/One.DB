-- =============================================
-- 15. USER_ROLE_LIST: Kullanici rol listesi (unified)
-- p_tenant_id = NULL: Tüm roller (global + tenant)
-- p_tenant_id = değer: Sadece belirtilen tenant'ın rolleri
-- Returns: JSONB {globalRoles, tenantRoles} veya sadece roles array
-- =============================================

DROP FUNCTION IF EXISTS security.user_role_list(BIGINT, BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.user_role_list(
    p_caller_id BIGINT,
    p_user_id BIGINT,
    p_tenant_id BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_caller_company_id BIGINT;
    v_has_platform_role BOOLEAN;
    v_user_company_id BIGINT;
    v_tenant_company_id BIGINT;
    v_global_roles JSONB;
    v_tenant_roles JSONB;
    v_roles JSONB;
    v_has_access BOOLEAN;
BEGIN
    -- 1. Yetki Kontrolü (Caller)
    SELECT
        u.company_id,
        EXISTS(
            SELECT 1
            FROM security.user_roles ur
            JOIN security.roles r ON ur.role_id = r.id
            WHERE ur.user_id = u.id AND ur.tenant_id IS NULL AND r.is_platform_role = TRUE
        )
    INTO v_caller_company_id, v_has_platform_role
    FROM security.users u
    WHERE u.id = p_caller_id AND u.status = 1;

    IF v_caller_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

    -- 2. Hedef Kullanıcı Kontrolü
    SELECT company_id FROM security.users WHERE id = p_user_id AND status = 1 INTO v_user_company_id;
    IF v_user_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- 3. Tenant scope kontrolü
    IF p_tenant_id IS NOT NULL THEN
        -- Tenant bilgisi
        SELECT company_id FROM core.tenants WHERE id = p_tenant_id INTO v_tenant_company_id;
        IF v_tenant_company_id IS NULL THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
        END IF;

        IF NOT v_has_platform_role THEN
            -- Hedef user aynı şirketten olmalı
            IF v_user_company_id != v_caller_company_id THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
            END IF;

            -- Tenant erişim kontrolü
            IF v_tenant_company_id = v_caller_company_id THEN
                -- companyadmin kontrolü
                IF NOT EXISTS(
                    SELECT 1 FROM security.user_roles ur
                    JOIN security.roles r ON ur.role_id = r.id
                    WHERE ur.user_id = p_caller_id AND ur.tenant_id IS NULL AND r.code = 'companyadmin'
                ) THEN
                    -- user_allowed_tenants kontrolü
                    SELECT EXISTS(
                        SELECT 1 FROM security.user_allowed_tenants
                        WHERE user_id = p_caller_id AND tenant_id = p_tenant_id
                    ) INTO v_has_access;

                    IF NOT v_has_access THEN
                        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.tenant-scope-denied';
                    END IF;
                END IF;
            ELSE
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
            END IF;
        END IF;

        -- Sadece belirtilen tenant'ın rollerini getir
        SELECT COALESCE(jsonb_agg(jsonb_build_object(
            'code', r.code,
            'name', r.name,
            'tenantId', ur.tenant_id,
            'tenantName', t.tenant_name,
            'assignedAt', ur.assigned_at,
            'assignedBy', ur.assigned_by
        )), '[]'::jsonb)
        INTO v_tenant_roles
        FROM security.user_roles ur
        JOIN security.roles r ON r.id = ur.role_id
        LEFT JOIN core.tenants t ON t.id = ur.tenant_id
        WHERE ur.user_id = p_user_id
          AND ur.tenant_id = p_tenant_id
          AND r.status = 1;

        -- Aynı format: {globalRoles: [], tenantRoles: [...]}
        RETURN jsonb_build_object(
            'globalRoles', '[]'::jsonb,
            'tenantRoles', v_tenant_roles
        );
    ELSE
        -- Tüm roller (global + tenant) - mevcut davranış
        IF NOT v_has_platform_role THEN
            IF v_user_company_id != v_caller_company_id THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
            END IF;
        END IF;

        -- Global roller (tenant_id IS NULL)
        SELECT COALESCE(jsonb_agg(jsonb_build_object(
            'code', r.code,
            'name', r.name,
            'assignedAt', ur.assigned_at,
            'assignedBy', ur.assigned_by
        )), '[]'::jsonb)
        INTO v_global_roles
        FROM security.user_roles ur
        JOIN security.roles r ON r.id = ur.role_id
        WHERE ur.user_id = p_user_id
          AND ur.tenant_id IS NULL
          AND r.status = 1;

        -- Tenant roller (tenant_id IS NOT NULL)
        SELECT COALESCE(jsonb_agg(jsonb_build_object(
            'tenantId', ur.tenant_id,
            'tenantName', t.tenant_name,
            'code', r.code,
            'name', r.name,
            'assignedAt', ur.assigned_at,
            'assignedBy', ur.assigned_by
        )), '[]'::jsonb)
        INTO v_tenant_roles
        FROM security.user_roles ur
        JOIN security.roles r ON r.id = ur.role_id
        JOIN core.tenants t ON t.id = ur.tenant_id
        WHERE ur.user_id = p_user_id
          AND ur.tenant_id IS NOT NULL
          AND r.status = 1;

        RETURN jsonb_build_object(
            'globalRoles', v_global_roles,
            'tenantRoles', v_tenant_roles
        );
    END IF;
END;
$$;

COMMENT ON FUNCTION security.user_role_list(BIGINT, BIGINT, BIGINT) IS 'Lists user roles. tenant_id=NULL returns all roles (global+tenant), tenant_id=value returns only that tenant''s roles. Enforces scope permissions.';

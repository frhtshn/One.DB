-- =============================================
-- 15. USER_ROLE_LIST: Kullanici rol listesi (unified)
-- p_client_id = NULL: Tüm roller (global + client)
-- p_client_id = değer: Sadece belirtilen client'ın rolleri
-- Returns: JSONB {globalRoles, clientRoles} veya sadece roles array
-- =============================================

DROP FUNCTION IF EXISTS security.user_role_list(BIGINT, BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.user_role_list(
    p_caller_id BIGINT,
    p_user_id BIGINT,
    p_client_id BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_caller_company_id BIGINT;
    v_has_platform_role BOOLEAN;
    v_user_company_id BIGINT;
    v_client_company_id BIGINT;
    v_global_roles JSONB;
    v_client_roles JSONB;
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
            WHERE ur.user_id = u.id AND ur.client_id IS NULL AND r.is_platform_role = TRUE
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

    -- 3. Client scope kontrolü
    IF p_client_id IS NOT NULL THEN
        -- Client bilgisi
        SELECT company_id FROM core.clients WHERE id = p_client_id INTO v_client_company_id;
        IF v_client_company_id IS NULL THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.client.not-found';
        END IF;

        IF NOT v_has_platform_role THEN
            -- Hedef user aynı şirketten olmalı
            IF v_user_company_id != v_caller_company_id THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
            END IF;

            -- Client erişim kontrolü
            IF v_client_company_id = v_caller_company_id THEN
                -- companyadmin kontrolü
                IF NOT EXISTS(
                    SELECT 1 FROM security.user_roles ur
                    JOIN security.roles r ON ur.role_id = r.id
                    WHERE ur.user_id = p_caller_id AND ur.client_id IS NULL AND r.code = 'companyadmin'
                ) THEN
                    -- user_allowed_clients kontrolü
                    SELECT EXISTS(
                        SELECT 1 FROM security.user_allowed_clients
                        WHERE user_id = p_caller_id AND client_id = p_client_id
                    ) INTO v_has_access;

                    IF NOT v_has_access THEN
                        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.client-scope-denied';
                    END IF;
                END IF;
            ELSE
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
            END IF;
        END IF;

        -- Sadece belirtilen client'ın rollerini getir
        SELECT COALESCE(jsonb_agg(jsonb_build_object(
            'code', r.code,
            'name', r.name,
            'clientId', ur.client_id,
            'clientName', t.client_name,
            'assignedAt', ur.assigned_at,
            'assignedBy', ur.assigned_by
        )), '[]'::jsonb)
        INTO v_client_roles
        FROM security.user_roles ur
        JOIN security.roles r ON r.id = ur.role_id
        LEFT JOIN core.clients t ON t.id = ur.client_id
        WHERE ur.user_id = p_user_id
          AND ur.client_id = p_client_id
          AND r.status = 1;

        -- Aynı format: {globalRoles: [], clientRoles: [...]}
        RETURN jsonb_build_object(
            'globalRoles', '[]'::jsonb,
            'clientRoles', v_client_roles
        );
    ELSE
        -- Tüm roller (global + client) - mevcut davranış
        IF NOT v_has_platform_role THEN
            IF v_user_company_id != v_caller_company_id THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
            END IF;
        END IF;

        -- Global roller (client_id IS NULL)
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
          AND ur.client_id IS NULL
          AND r.status = 1;

        -- Client roller (client_id IS NOT NULL)
        SELECT COALESCE(jsonb_agg(jsonb_build_object(
            'clientId', ur.client_id,
            'clientName', t.client_name,
            'code', r.code,
            'name', r.name,
            'assignedAt', ur.assigned_at,
            'assignedBy', ur.assigned_by
        )), '[]'::jsonb)
        INTO v_client_roles
        FROM security.user_roles ur
        JOIN security.roles r ON r.id = ur.role_id
        JOIN core.clients t ON t.id = ur.client_id
        WHERE ur.user_id = p_user_id
          AND ur.client_id IS NOT NULL
          AND r.status = 1;

        RETURN jsonb_build_object(
            'globalRoles', v_global_roles,
            'clientRoles', v_client_roles
        );
    END IF;
END;
$$;

COMMENT ON FUNCTION security.user_role_list(BIGINT, BIGINT, BIGINT) IS 'Lists user roles. client_id=NULL returns all roles (global+client), client_id=value returns only that client''s roles. Enforces scope permissions.';

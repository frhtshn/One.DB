-- =============================================
-- 15. USER_ROLE_LIST: Kullanici rol listesi
-- Returns: JSONB {globalRoles, tenantRoles}
-- =============================================

DROP FUNCTION IF EXISTS security.user_role_list(BIGINT, BIGINT);


CREATE OR REPLACE FUNCTION security.user_role_list(
    p_caller_id BIGINT,
    p_user_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_caller_company_id BIGINT;
    v_has_platform_role BOOLEAN;
    v_user_company_id BIGINT;
    v_user_exists BOOLEAN;
    v_global_roles JSONB;
    v_tenant_roles JSONB;
BEGIN
    -- 1. Yetki Kontrolü (Caller)
    SELECT
        u.company_id,
        EXISTS(
            SELECT 1
            FROM security.user_roles ur
            JOIN security.roles r ON ur.role_id = r.id
            WHERE ur.user_id = u.id AND r.is_platform_role = TRUE
        )
    INTO v_caller_company_id, v_has_platform_role
    FROM security.users u
    WHERE u.id = p_caller_id AND u.status = 1;

    IF v_caller_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    -- 2. Hedef Kullanıcı Kontrolü
    SELECT company_id FROM security.users WHERE id = p_user_id AND status = 1 INTO v_user_company_id;
    IF v_user_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.target-user.not-found';
    END IF;

    -- 3. Platform rolü yoksa, company scope kontrolü yap
    IF NOT v_has_platform_role THEN
        IF v_user_company_id != v_caller_company_id THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
        END IF;
    END IF;

    -- Get global roles
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'code', r.code,
        'name', r.name,
        'assignedAt', ur.assigned_at,
        'assignedBy', ur.assigned_by
    )), '[]'::jsonb)
    INTO v_global_roles
    FROM security.user_roles ur
    JOIN security.roles r ON r.id = ur.role_id
    WHERE ur.user_id = p_user_id AND r.status = 1;

    -- Get tenant roles
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'tenantId', utr.tenant_id,
        'code', r.code,
        'name', r.name,
        'assignedAt', utr.assigned_at,
        'assignedBy', utr.assigned_by
    )), '[]'::jsonb)
    INTO v_tenant_roles
    FROM security.user_tenant_roles utr
    JOIN security.roles r ON r.id = utr.role_id
    WHERE utr.user_id = p_user_id AND r.status = 1;

    RETURN jsonb_build_object(
        'globalRoles', v_global_roles,
        'tenantRoles', v_tenant_roles
    );
END;
$$;

COMMENT ON FUNCTION security.user_role_list(BIGINT, BIGINT) IS 'Lists usage roles (global and tenant-specific) with permission check (Caller ID). Non-platform users are restricted to their company.';

-- ================================================================
-- USER_GET: Kullanıcı detayı (roller dahil)
-- ================================================================

DROP FUNCTION IF EXISTS security.user_get(BIGINT);

CREATE OR REPLACE FUNCTION security.user_get(
    p_user_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
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
        'createdAt', u.created_at,
        'updatedAt', u.updated_at,
        'companyId', u.company_id,
        'companyName', c.company_name,
        'globalRoles', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'roleId', r.id,
                'roleCode', r.code,
                'roleName', r.name
            ) ORDER BY r.id)
            FROM security.user_roles ur
            JOIN security.roles r ON r.id = ur.role_id
            WHERE ur.user_id = u.id
        ), '[]'::jsonb),
        'tenantRoles', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'tenantId', utr.tenant_id,
                'roleId', r.id,
                'roleCode', r.code,
                'roleName', r.name
            ) ORDER BY utr.tenant_id, r.id)
            FROM security.user_tenant_roles utr
            JOIN security.roles r ON r.id = utr.role_id
            WHERE utr.user_id = u.id
        ), '[]'::jsonb),
        'allowedTenants', COALESCE((
            SELECT jsonb_agg(uat.tenant_id ORDER BY uat.tenant_id)
            FROM security.user_allowed_tenants uat
            WHERE uat.user_id = u.id
        ), '[]'::jsonb)
    )
    INTO v_result
    FROM security.users u
    LEFT JOIN core.companies c ON c.id = u.company_id
    WHERE u.id = p_user_id;

    -- Kullanıcı bulunamadıysa hata fırlat
    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.user.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION security.user_get IS 'Returns user details including company info, global roles, tenant roles, and allowed tenants';

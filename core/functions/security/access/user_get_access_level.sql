-- ============================================================================
-- FUNCTION: security.user_get_access_level
-- ============================================================================
-- Purpose: Returns the caller's access level and scope information in a single query.
-- This is the foundation for all IDOR controls - other helpers use this.
-- ============================================================================
-- Parameters:
--   p_caller_id: User ID to check
-- ============================================================================
-- Return Values:
--   user_id: User ID
--   company_id: User's associated company
--   role_code: Highest level role code
--   role_level: Role level (100=superadmin, 10=user)
--   is_platform_role: Is it a platform role? (superadmin, admin)
--   allowed_tenant_ids: Accessible tenant IDs (NULL = unlimited)
--   allowed_company_ids: Accessible company IDs (NULL = unlimited)
-- ============================================================================
-- Usage:
--   SELECT * FROM security.user_get_access_level(123);
--
--   -- .NET Dapper
--   var access = await conn.QuerySingleOrDefaultAsync<UserAccess>(
--       "SELECT * FROM security.user_get_access_level(@callerId)",
--       new { callerId });
-- ============================================================================

DROP FUNCTION IF EXISTS security.user_get_access_level(BIGINT);

CREATE OR REPLACE FUNCTION security.user_get_access_level(
    p_caller_id BIGINT
) RETURNS TABLE (
    user_id BIGINT,
    company_id BIGINT,
    role_code VARCHAR(50),
    role_level INT,
    is_platform_role BOOLEAN,
    allowed_tenant_ids BIGINT[],
    allowed_company_ids BIGINT[]
) AS $$
DECLARE
    v_user RECORD;
    v_tenant_ids BIGINT[];
    v_company_ids BIGINT[];
BEGIN
    -- Get user and highest role info (global role - tenant_id IS NULL)
    SELECT
        u.id,
        u.company_id,
        r.code,
        r.level,
        r.is_platform_role
    INTO v_user
    FROM security.users u
    JOIN security.user_roles ur ON u.id = ur.user_id AND ur.tenant_id IS NULL
    JOIN security.roles r ON ur.role_id = r.id
    WHERE u.id = p_caller_id
      AND u.status = 1
    ORDER BY r.level DESC
    LIMIT 1;

    -- Return empty if user not found
    IF v_user IS NULL THEN
        RETURN;
    END IF;

    -- Determine access scope
    IF v_user.level >= 90 THEN
        -- SuperAdmin (100) / Admin (90): Access to all tenants and companies
        v_tenant_ids := NULL;  -- NULL = unlimited
        v_company_ids := NULL;
    ELSIF v_user.code = 'companyadmin' THEN
        -- CompanyAdmin: Access to all tenants in their company
        SELECT ARRAY_AGG(t.id) INTO v_tenant_ids
        FROM core.tenants t
        WHERE t.company_id = v_user.company_id;

        v_company_ids := ARRAY[v_user.company_id];
    ELSE
        -- Others: From user_allowed_tenants table
        SELECT ARRAY_AGG(uat.tenant_id) INTO v_tenant_ids
        FROM security.user_allowed_tenants uat
        WHERE uat.user_id = p_caller_id;

        -- Companies of allowed tenants
        SELECT ARRAY_AGG(DISTINCT t.company_id) INTO v_company_ids
        FROM core.tenants t
        WHERE t.id = ANY(v_tenant_ids);

        -- Also add their own company
        IF v_company_ids IS NULL THEN
            v_company_ids := ARRAY[v_user.company_id];
        ELSIF NOT (v_user.company_id = ANY(v_company_ids)) THEN
            v_company_ids := v_company_ids || v_user.company_id;
        END IF;
    END IF;

    RETURN QUERY SELECT
        v_user.id,
        v_user.company_id,
        v_user.code,
        v_user.level,
        v_user.is_platform_role,
        v_tenant_ids,
        v_company_ids;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION security.user_get_access_level(BIGINT) IS
'Returns caller access level and scope info. Foundation for all IDOR controls.';

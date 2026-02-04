-- ============================================================================
-- FUNCTION: security.user_can_access_tenant
-- ============================================================================
-- Purpose: Checks if the caller can access the specified tenant.
-- ============================================================================
-- Parameters:
--   p_caller_id: User ID performing the action
--   p_tenant_id: Tenant ID to access
-- ============================================================================
-- Access Rules:
--   - SuperAdmin/Admin (level >= 90): Access to all tenants
--   - CompanyAdmin: Access to tenants in their company
--   - Others: Access via user_allowed_tenants table
-- ============================================================================
-- Usage:
--   -- PL/pgSQL (boolean check)
--   IF NOT security.user_can_access_tenant(p_caller_id, p_tenant_id) THEN
--       RAISE EXCEPTION 'ERR_ACCESS_DENIED';
--   END IF;
--
--   -- PL/pgSQL (guard clause - throws exception)
--   PERFORM security.user_assert_access_tenant(p_caller_id, p_tenant_id);
--
--   -- .NET Dapper
--   var canAccess = await conn.QuerySingleAsync<bool>(
--       "SELECT security.user_can_access_tenant(@callerId, @tenantId)",
--       new { callerId, tenantId });
-- ============================================================================

DROP FUNCTION IF EXISTS security.user_can_access_tenant(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.user_can_access_tenant(
    p_caller_id BIGINT,
    p_tenant_id BIGINT
) RETURNS BOOLEAN AS $$
DECLARE
    v_access RECORD;
BEGIN
    -- NULL check
    IF p_caller_id IS NULL OR p_tenant_id IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Get caller access info
    SELECT * INTO v_access
    FROM security.user_get_access_level(p_caller_id);

    -- Caller not found
    IF v_access.user_id IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Platform Admin (SuperAdmin/Admin): Access to all tenants
    -- allowed_tenant_ids NULL means unlimited access
    IF v_access.allowed_tenant_ids IS NULL THEN
        RETURN TRUE;
    END IF;

    -- Others: Is it in the allowed list?
    RETURN p_tenant_id = ANY(v_access.allowed_tenant_ids);
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION security.user_can_access_tenant(BIGINT, BIGINT) IS
'Checks if caller can access the specified tenant. Used for IDOR protection.';

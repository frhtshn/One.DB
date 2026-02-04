-- ============================================================================
-- FUNCTION: security.user_assert_access_tenant
-- ============================================================================
-- Purpose: Guard clause version - raises exception if access denied.
-- Use this in database functions that should fail fast on unauthorized access.
-- ============================================================================
-- Parameters:
--   p_caller_id: User ID performing the action
--   p_tenant_id: Tenant ID to access
-- ============================================================================
-- Usage:
--   -- At the beginning of a function
--   PERFORM security.user_assert_access_tenant(p_caller_id, p_tenant_id);
--   -- Continues only if access is granted
-- ============================================================================

DROP FUNCTION IF EXISTS security.user_assert_access_tenant(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.user_assert_access_tenant(
    p_caller_id BIGINT,
    p_tenant_id BIGINT
) RETURNS VOID AS $$
BEGIN
    IF NOT security.user_can_access_tenant(p_caller_id, p_tenant_id) THEN
        RAISE EXCEPTION USING
            ERRCODE = 'P0403',
            MESSAGE = 'error.access.tenant-scope-denied';
    END IF;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION security.user_assert_access_tenant(BIGINT, BIGINT) IS
'Guard clause: raises exception if caller cannot access the tenant.';

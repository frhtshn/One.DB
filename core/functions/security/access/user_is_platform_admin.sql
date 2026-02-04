-- ============================================================================
-- FUNCTION: security.user_is_platform_admin
-- ============================================================================
-- Purpose: Checks if the caller has a platform-level admin role.
-- Platform admins are SuperAdmin (100) and Admin (90) with is_platform_role=TRUE.
-- ============================================================================
-- Parameters:
--   p_caller_id: User ID to check
-- ============================================================================
-- Usage:
--   -- PL/pgSQL (boolean check)
--   IF NOT security.user_is_platform_admin(p_caller_id) THEN
--       RAISE EXCEPTION 'ERR_ACCESS_DENIED';
--   END IF;
--
--   -- PL/pgSQL (guard clause - throws exception)
--   PERFORM security.user_assert_platform_admin(p_caller_id);
--
--   -- .NET Dapper
--   var isPlatformAdmin = await conn.QuerySingleAsync<bool>(
--       "SELECT security.user_is_platform_admin(@callerId)",
--       new { callerId });
-- ============================================================================

DROP FUNCTION IF EXISTS security.user_is_platform_admin(BIGINT);

CREATE OR REPLACE FUNCTION security.user_is_platform_admin(
    p_caller_id BIGINT
) RETURNS BOOLEAN AS $$
DECLARE
    v_is_platform_role BOOLEAN;
BEGIN
    -- NULL check
    IF p_caller_id IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Get platform role status from access level helper
    SELECT is_platform_role INTO v_is_platform_role
    FROM security.user_get_access_level(p_caller_id);

    -- Return result (FALSE if user not found or not platform admin)
    RETURN COALESCE(v_is_platform_role, FALSE);
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION security.user_is_platform_admin(BIGINT) IS
'Checks if caller has platform admin role (SuperAdmin or Admin).';

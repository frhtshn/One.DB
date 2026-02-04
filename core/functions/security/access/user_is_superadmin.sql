-- ============================================================================
-- FUNCTION: security.user_is_superadmin
-- ============================================================================
-- Purpose: Checks if the caller has the SuperAdmin role (level 100).
-- This is the highest privilege level - use for critical system operations.
-- ============================================================================
-- Parameters:
--   p_caller_id: User ID to check
-- ============================================================================
-- Usage:
--   -- PL/pgSQL (boolean check)
--   IF NOT security.user_is_superadmin(p_caller_id) THEN
--       RAISE EXCEPTION 'ERR_ACCESS_DENIED';
--   END IF;
--
--   -- PL/pgSQL (guard clause - throws exception)
--   PERFORM security.user_assert_superadmin(p_caller_id);
--
--   -- .NET Dapper
--   var isSuperAdmin = await conn.QuerySingleAsync<bool>(
--       "SELECT security.user_is_superadmin(@callerId)",
--       new { callerId });
-- ============================================================================

DROP FUNCTION IF EXISTS security.user_is_superadmin(BIGINT);

CREATE OR REPLACE FUNCTION security.user_is_superadmin(
    p_caller_id BIGINT
) RETURNS BOOLEAN AS $$
DECLARE
    v_role_level INT;
BEGIN
    -- NULL check
    IF p_caller_id IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Get role level from access level helper
    SELECT role_level INTO v_role_level
    FROM security.user_get_access_level(p_caller_id);

    -- SuperAdmin is level 100
    RETURN COALESCE(v_role_level, 0) >= 100;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION security.user_is_superadmin(BIGINT) IS
'Checks if caller has SuperAdmin role (level 100). Highest privilege level.';

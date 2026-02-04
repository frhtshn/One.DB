-- ============================================================================
-- FUNCTION: security.user_assert_superadmin
-- ============================================================================
-- Purpose: Guard clause version - raises exception if caller is not SuperAdmin.
-- Use this in database functions that require the highest privilege level.
-- ============================================================================
-- Parameters:
--   p_caller_id: User ID performing the action
-- ============================================================================
-- Usage:
--   -- At the beginning of a function
--   PERFORM security.user_assert_superadmin(p_caller_id);
--   -- Continues only if caller is SuperAdmin
-- ============================================================================

DROP FUNCTION IF EXISTS security.user_assert_superadmin(BIGINT);

CREATE OR REPLACE FUNCTION security.user_assert_superadmin(
    p_caller_id BIGINT
) RETURNS VOID AS $$
BEGIN
    IF NOT security.user_is_superadmin(p_caller_id) THEN
        RAISE EXCEPTION USING
            ERRCODE = 'P0403',
            MESSAGE = 'error.access.unauthorized';
    END IF;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION security.user_assert_superadmin(BIGINT) IS
'Guard clause: raises exception if caller is not SuperAdmin.';

-- ============================================================================
-- FUNCTION: security.user_assert_manage_user
-- ============================================================================
-- Purpose: Guard clause version - raises exception if management denied.
-- Use this in database functions that should fail fast on unauthorized access.
-- ============================================================================
-- Parameters:
--   p_caller_id: User ID performing the action
--   p_target_user_id: User ID to be managed (NULL = new user)
-- ============================================================================
-- Usage:
--   -- At the beginning of a function
--   PERFORM security.user_assert_manage_user(p_caller_id, p_target_user_id);
--   -- Continues only if management is allowed
-- ============================================================================

DROP FUNCTION IF EXISTS security.user_assert_manage_user(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.user_assert_manage_user(
    p_caller_id BIGINT,
    p_target_user_id BIGINT
) RETURNS VOID AS $$
BEGIN
    IF NOT security.user_can_manage_user(p_caller_id, p_target_user_id) THEN
        RAISE EXCEPTION USING
            ERRCODE = 'P0403',
            MESSAGE = 'error.access.unauthorized';
    END IF;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION security.user_assert_manage_user(BIGINT, BIGINT) IS
'Guard clause: raises exception if caller cannot manage the target user.';

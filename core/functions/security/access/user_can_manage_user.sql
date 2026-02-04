-- ============================================================================
-- FUNCTION: security.user_can_manage_user
-- ============================================================================
-- Purpose: Checks if the caller can manage the target user.
-- Used for User CRUD operations (create, update, delete).
-- ============================================================================
-- Parameters:
--   p_caller_id: User ID performing the action
--   p_target_user_id: User ID to be managed (NULL = new user)
-- ============================================================================
-- Management Rules:
--   1. Level Check: Caller must have HIGHER level than target
--   2. Company Check: CompanyAdmin and below can only manage users in their company
--   3. Self-management: User can view their own profile but cannot change roles
-- ============================================================================
-- Usage:
--   -- PL/pgSQL (boolean check)
--   IF NOT security.user_can_manage_user(p_caller_id, p_target_user_id) THEN
--       RAISE EXCEPTION 'ERR_ACCESS_DENIED';
--   END IF;
--
--   -- PL/pgSQL (guard clause - throws exception)
--   PERFORM security.user_assert_manage_user(p_caller_id, p_target_user_id);
--
--   -- .NET Dapper
--   var canManage = await conn.QuerySingleAsync<bool>(
--       "SELECT security.user_can_manage_user(@callerId, @targetUserId)",
--       new { callerId, targetUserId });
-- ============================================================================

DROP FUNCTION IF EXISTS security.user_can_manage_user(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.user_can_manage_user(
    p_caller_id BIGINT,
    p_target_user_id BIGINT
) RETURNS BOOLEAN AS $$
DECLARE
    v_caller RECORD;
    v_target RECORD;
BEGIN
    -- NULL check (caller is required)
    IF p_caller_id IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Get caller access info
    SELECT * INTO v_caller
    FROM security.user_get_access_level(p_caller_id);

    -- Caller not found
    IF v_caller.user_id IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Target NULL means creating a new user - only check level
    IF p_target_user_id IS NULL THEN
        -- At least operator level required (for user creation permission)
        RETURN v_caller.role_level >= 40;
    END IF;

    -- Self-management: View OK, but this function is for "manage"
    -- User profile updates should be in a separate function
    IF p_caller_id = p_target_user_id THEN
        RETURN FALSE;  -- Cannot manage self (role changes, etc.)
    END IF;

    -- Get target access info
    SELECT * INTO v_target
    FROM security.user_get_access_level(p_target_user_id);

    -- Target not found (deleted/deactivated user) - can be managed
    IF v_target.user_id IS NULL THEN
        RETURN TRUE;
    END IF;

    -- Level Check: Caller must have higher level
    -- Equal level cannot manage each other (e.g., CompanyAdmin cannot manage another CompanyAdmin)
    IF v_caller.role_level <= v_target.role_level THEN
        RETURN FALSE;
    END IF;

    -- Company Check (except Platform Admin)
    IF v_caller.role_level < 90 THEN
        -- CompanyAdmin and below: Can only manage users in their company
        IF v_caller.company_id != v_target.company_id THEN
            RETURN FALSE;
        END IF;
    END IF;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION security.user_can_manage_user(BIGINT, BIGINT) IS
'Checks if caller can manage the target user. Level and company based IDOR protection.';
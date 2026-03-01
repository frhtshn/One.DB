-- ============================================================================
-- FUNCTION: security.user_can_access_client
-- ============================================================================
-- Purpose: Checks if the caller can access the specified client.
-- ============================================================================
-- Parameters:
--   p_caller_id: User ID performing the action
--   p_client_id: Client ID to access
-- ============================================================================
-- Access Rules:
--   - SuperAdmin/Admin (level >= 90): Access to all clients
--   - CompanyAdmin: Access to clients in their company
--   - Others: Access via user_allowed_clients table
-- ============================================================================
-- Usage:
--   -- PL/pgSQL (boolean check)
--   IF NOT security.user_can_access_client(p_caller_id, p_client_id) THEN
--       RAISE EXCEPTION 'ERR_ACCESS_DENIED';
--   END IF;
--
--   -- PL/pgSQL (guard clause - throws exception)
--   PERFORM security.user_assert_access_client(p_caller_id, p_client_id);
--
--   -- .NET Dapper
--   var canAccess = await conn.QuerySingleAsync<bool>(
--       "SELECT security.user_can_access_client(@callerId, @clientId)",
--       new { callerId, clientId });
-- ============================================================================

DROP FUNCTION IF EXISTS security.user_can_access_client(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.user_can_access_client(
    p_caller_id BIGINT,
    p_client_id BIGINT
) RETURNS BOOLEAN AS $$
DECLARE
    v_access RECORD;
BEGIN
    -- NULL check
    IF p_caller_id IS NULL OR p_client_id IS NULL THEN
        RETURN FALSE;
    END IF;

    -- System call bypass (grain-to-grain, Reminder, HostedService)
    -- -1 = SystemCallerId, C# tarafinda SystemConstants.SystemCallerId ile eslesir
    IF p_caller_id = -1 THEN
        RETURN TRUE;
    END IF;

    -- Get caller access info
    SELECT * INTO v_access
    FROM security.user_get_access_level(p_caller_id);

    -- Caller not found
    IF v_access.user_id IS NULL THEN
        RETURN FALSE;
    END IF;

    -- Platform Admin (SuperAdmin/Admin): Access to all clients
    -- allowed_client_ids NULL means unlimited access
    IF v_access.allowed_client_ids IS NULL THEN
        RETURN TRUE;
    END IF;

    -- Others: Is it in the allowed list?
    RETURN p_client_id = ANY(v_access.allowed_client_ids);
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION security.user_can_access_client(BIGINT, BIGINT) IS
'Checks if caller can access the specified client. Used for IDOR protection.';

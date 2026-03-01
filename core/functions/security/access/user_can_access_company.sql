-- ============================================================================
-- FUNCTION: security.user_can_access_company
-- ============================================================================
-- Purpose: Checks if the caller can access the specified company.
-- ============================================================================
-- Parameters:
--   p_caller_id: User ID performing the action
--   p_company_id: Company ID to access
-- ============================================================================
-- Access Rules:
--   - SuperAdmin/Admin (level >= 90): Access to all companies
--   - CompanyAdmin and below: Access only to their own company
--   - Client-based access: Access to companies of their allowed clients
-- ============================================================================
-- Usage:
--   -- PL/pgSQL (boolean check)
--   IF NOT security.user_can_access_company(p_caller_id, p_company_id) THEN
--       RAISE EXCEPTION 'ERR_ACCESS_DENIED';
--   END IF;
--
--   -- PL/pgSQL (guard clause - throws exception)
--   PERFORM security.user_assert_access_company(p_caller_id, p_company_id);
--
--   -- .NET Dapper
--   var canAccess = await conn.QuerySingleAsync<bool>(
--       "SELECT security.user_can_access_company(@callerId, @companyId)",
--       new { callerId, companyId });
-- ============================================================================

DROP FUNCTION IF EXISTS security.user_can_access_company(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.user_can_access_company(
    p_caller_id BIGINT,
    p_company_id BIGINT
) RETURNS BOOLEAN AS $$
DECLARE
    v_access RECORD;
BEGIN
    -- NULL check
    IF p_caller_id IS NULL OR p_company_id IS NULL THEN
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

    -- Platform Admin (SuperAdmin/Admin): Access to all companies
    -- allowed_company_ids NULL means unlimited access
    IF v_access.allowed_company_ids IS NULL THEN
        RETURN TRUE;
    END IF;

    -- Others: Is it in the allowed list?
    RETURN p_company_id = ANY(v_access.allowed_company_ids);
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER;

COMMENT ON FUNCTION security.user_can_access_company(BIGINT, BIGINT) IS
'Checks if caller can access the specified company. Used for IDOR protection.';

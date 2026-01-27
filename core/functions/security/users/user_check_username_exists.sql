-- ================================================================
-- USER_CHECK_USERNAME_EXISTS: Username+company benzersizlik kontrolü
-- Update senaryoları için excludeUserId parametresi
-- ================================================================

DROP FUNCTION IF EXISTS security.user_check_username_exists(TEXT, BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION security.user_check_username_exists(
    p_username TEXT,
    p_company_id BIGINT,
    p_exclude_user_id BIGINT DEFAULT NULL
)
RETURNS TABLE(is_exists BOOLEAN)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT EXISTS (
        SELECT 1
        FROM security.users
        WHERE username = LOWER(TRIM(p_username))
          AND company_id = p_company_id
          AND (p_exclude_user_id IS NULL OR id != p_exclude_user_id)
    );
END;
$$;

COMMENT ON FUNCTION security.user_check_username_exists IS 'Checks if username exists in company. Use excludeUserId for update scenarios.';

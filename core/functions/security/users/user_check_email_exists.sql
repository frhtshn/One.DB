-- ================================================================
-- USER_CHECK_EMAIL_EXISTS: Email benzersizlik kontrolü
-- Update senaryoları için excludeUserId parametresi
-- ================================================================

DROP FUNCTION IF EXISTS security.user_check_email_exists(TEXT, BIGINT);

CREATE OR REPLACE FUNCTION security.user_check_email_exists(
    p_email TEXT,
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
        WHERE email = LOWER(TRIM(p_email))
          AND (p_exclude_user_id IS NULL OR id != p_exclude_user_id)
    );
END;
$$;

COMMENT ON FUNCTION security.user_check_email_exists IS 'Checks if email exists. Use excludeUserId for update scenarios.';

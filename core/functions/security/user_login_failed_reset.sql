-- ================================================================
-- USER_LOGIN_FAILED_RESET: Başarılı login sonrası sayacı sıfırla
-- ================================================================

DROP FUNCTION IF EXISTS security.user_login_failed_reset(BIGINT);

CREATE OR REPLACE FUNCTION security.user_login_failed_reset(
    p_user_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE security.users
    SET
        failed_login_count = 0,
        is_locked = FALSE,
        locked_until = NULL,
        last_login_at = NOW()
    WHERE id = p_user_id;
END;
$$;

COMMENT ON FUNCTION security.user_login_failed_reset IS 'Resets failed login count after successful login';

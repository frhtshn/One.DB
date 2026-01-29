-- ================================================================
-- SESSION_BELONGS_TO_USER: Session ownership kontrolü
-- ================================================================
CREATE OR REPLACE FUNCTION security.session_belongs_to_user(
    p_session_id VARCHAR(50),
    p_user_id BIGINT
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
AS $$
    SELECT EXISTS(
        SELECT 1
        FROM security.user_sessions
        WHERE id = p_session_id
          AND user_id = p_user_id
          AND is_revoked = FALSE
          AND expires_at > NOW()
    );
$$;

COMMENT ON FUNCTION security.session_belongs_to_user IS 'Checks if session belongs to user';

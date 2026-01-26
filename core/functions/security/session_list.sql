-- ================================================================
-- SESSION_LIST: Kullanıcının aktif oturumlarını listele
-- ================================================================

DROP FUNCTION IF EXISTS security.session_list(BIGINT);

CREATE OR REPLACE FUNCTION security.session_list(
    p_user_id BIGINT
)
RETURNS TABLE (
    session_id VARCHAR(50),
    ip_address VARCHAR(50),
    user_agent VARCHAR(500),
    device_name VARCHAR(100),
    created_at TIMESTAMPTZ,
    last_activity_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.id,
        s.ip_address,
        s.user_agent,
        s.device_name,
        s.created_at,
        s.last_activity_at,
        s.expires_at
    FROM security.user_sessions s
    WHERE s.user_id = p_user_id
    AND s.is_revoked = FALSE
    AND s.expires_at > NOW()
    ORDER BY s.last_activity_at DESC;
END;
$$;

COMMENT ON FUNCTION security.session_list IS 'Lists active sessions for a user';

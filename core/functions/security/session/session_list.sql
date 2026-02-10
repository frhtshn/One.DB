-- ================================================================
-- SESSION_LIST: Kullanıcının aktif oturumlarını listele
-- GeoIP bilgileri ile birlikte döner
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
    country_code CHAR(2),
    region VARCHAR(100),
    city VARCHAR(200),
    is_proxy BOOLEAN,
    is_hosting BOOLEAN,
    is_mobile BOOLEAN,
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
        s.country_code,
        s.region,
        s.city,
        s.is_proxy,
        s.is_hosting,
        s.is_mobile,
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

COMMENT ON FUNCTION security.session_list IS 'Lists active sessions for a user with GeoIP data';

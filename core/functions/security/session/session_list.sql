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
    country VARCHAR(100),
    country_code CHAR(2),
    continent VARCHAR(100),
    continent_code CHAR(2),
    region VARCHAR(100),
    region_name VARCHAR(200),
    city VARCHAR(200),
    district VARCHAR(200),
    zip VARCHAR(20),
    lat DECIMAL(9,6),
    lon DECIMAL(9,6),
    timezone VARCHAR(100),
    utc_offset INTEGER,
    currency VARCHAR(10),
    isp VARCHAR(300),
    org VARCHAR(300),
    as_number VARCHAR(200),
    as_name VARCHAR(300),
    reverse_dns VARCHAR(300),
    is_mobile BOOLEAN,
    is_proxy BOOLEAN,
    is_hosting BOOLEAN,
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
        s.country,
        s.country_code,
        s.continent,
        s.continent_code,
        s.region,
        s.region_name,
        s.city,
        s.district,
        s.zip,
        s.lat,
        s.lon,
        s.timezone,
        s.utc_offset,
        s.currency,
        s.isp,
        s.org,
        s.as_number,
        s.as_name,
        s.reverse_dns,
        s.is_mobile,
        s.is_proxy,
        s.is_hosting,
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

COMMENT ON FUNCTION security.session_list IS 'Lists active sessions for a user with full GeoIP data';

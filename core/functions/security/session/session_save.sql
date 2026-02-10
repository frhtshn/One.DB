-- ================================================================
-- SESSION_SAVE: Yeni oturum kaydet veya güncelle
-- GeoIP bilgileri ip-api.com'dan çözümlenmiş olarak gelir
-- ================================================================

DROP FUNCTION IF EXISTS security.session_save(VARCHAR, BIGINT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, TIMESTAMPTZ);
DROP FUNCTION IF EXISTS security.session_save(VARCHAR, BIGINT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, TIMESTAMPTZ, CHAR, VARCHAR, VARCHAR, BOOLEAN, BOOLEAN, BOOLEAN);

CREATE OR REPLACE FUNCTION security.session_save(
    p_session_id VARCHAR(50),
    p_user_id BIGINT,
    p_refresh_token_id VARCHAR(100),
    p_ip_address VARCHAR(50),
    p_user_agent VARCHAR(500),
    p_device_name VARCHAR(100),
    p_expires_at TIMESTAMPTZ,
    p_country_code CHAR(2) DEFAULT NULL,         -- GeoIP ülke kodu
    p_region VARCHAR(100) DEFAULT NULL,           -- GeoIP bölge
    p_city VARCHAR(200) DEFAULT NULL,             -- GeoIP şehir
    p_is_proxy BOOLEAN DEFAULT FALSE,             -- VPN/Proxy bayrağı
    p_is_hosting BOOLEAN DEFAULT FALSE,           -- Datacenter bayrağı
    p_is_mobile BOOLEAN DEFAULT FALSE             -- Mobil bağlantı bayrağı
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO security.user_sessions (
        id, user_id, refresh_token_id, ip_address, user_agent, device_name,
        expires_at, country_code, region, city, is_proxy, is_hosting, is_mobile
    )
    VALUES (
        p_session_id, p_user_id, p_refresh_token_id, p_ip_address, p_user_agent, p_device_name,
        p_expires_at, p_country_code, p_region, p_city,
        COALESCE(p_is_proxy, FALSE), COALESCE(p_is_hosting, FALSE), COALESCE(p_is_mobile, FALSE)
    )
    ON CONFLICT (id) DO UPDATE
    SET
        refresh_token_id = EXCLUDED.refresh_token_id,
        last_activity_at = NOW(),
        ip_address       = EXCLUDED.ip_address,
        user_agent       = EXCLUDED.user_agent,
        country_code     = EXCLUDED.country_code,
        region           = EXCLUDED.region,
        city             = EXCLUDED.city,
        is_proxy         = EXCLUDED.is_proxy,
        is_hosting       = EXCLUDED.is_hosting,
        is_mobile        = EXCLUDED.is_mobile;
END;
$$;

COMMENT ON FUNCTION security.session_save IS 'Saves a new session or updates existing one with GeoIP data';

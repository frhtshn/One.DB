-- ================================================================
-- LOGIN_SESSION_CREATE: Oyuncu oturumu başlatır
-- Başarılı giriş sonrası çağrılır
-- GeoIP bilgileri ip-api.com'dan çözümlenmiş olarak gelir
-- ================================================================

DROP FUNCTION IF EXISTS player_audit.login_session_create(UUID,BIGINT,INET,VARCHAR,VARCHAR,VARCHAR,CHAR,VARCHAR,CHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,DECIMAL,DECIMAL,VARCHAR,INTEGER,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,BOOLEAN,BOOLEAN,BOOLEAN);

CREATE OR REPLACE FUNCTION player_audit.login_session_create(
    p_session_token      UUID,                       -- Oturum token'ı
    p_player_id          BIGINT,                     -- Player ID
    p_ip_address         INET,                       -- IP adresi
    p_user_agent         VARCHAR(500) DEFAULT NULL,   -- Tarayıcı bilgisi
    p_device_fingerprint VARCHAR(64) DEFAULT NULL,    -- Cihaz parmak izi
    p_country            VARCHAR(100) DEFAULT NULL,   -- GeoIP ülke adı
    p_country_code       CHAR(2) DEFAULT NULL,        -- GeoIP ülke kodu
    p_continent          VARCHAR(100) DEFAULT NULL,   -- GeoIP kıta adı
    p_continent_code     CHAR(2) DEFAULT NULL,        -- GeoIP kıta kodu
    p_region             VARCHAR(100) DEFAULT NULL,   -- GeoIP bölge kısa kodu
    p_region_name        VARCHAR(200) DEFAULT NULL,   -- GeoIP bölge tam adı
    p_city               VARCHAR(200) DEFAULT NULL,   -- GeoIP şehir
    p_district           VARCHAR(200) DEFAULT NULL,   -- GeoIP ilçe/semt
    p_zip                VARCHAR(20) DEFAULT NULL,    -- GeoIP posta kodu
    p_lat                DECIMAL(9,6) DEFAULT NULL,   -- GeoIP enlem
    p_lon                DECIMAL(9,6) DEFAULT NULL,   -- GeoIP boylam
    p_timezone           VARCHAR(100) DEFAULT NULL,   -- GeoIP timezone
    p_utc_offset         INTEGER DEFAULT NULL,        -- GeoIP UTC offset (saniye)
    p_currency           VARCHAR(10) DEFAULT NULL,    -- GeoIP para birimi kodu
    p_isp                VARCHAR(300) DEFAULT NULL,   -- GeoIP ISP
    p_org                VARCHAR(300) DEFAULT NULL,   -- GeoIP organizasyon
    p_as_number          VARCHAR(200) DEFAULT NULL,   -- GeoIP AS numarası
    p_as_name            VARCHAR(300) DEFAULT NULL,   -- GeoIP AS organizasyon adı
    p_reverse_dns        VARCHAR(300) DEFAULT NULL,   -- GeoIP reverse DNS
    p_is_mobile          BOOLEAN DEFAULT FALSE,       -- Mobil bağlantı bayrağı
    p_is_proxy           BOOLEAN DEFAULT FALSE,       -- VPN/Proxy bayrağı
    p_is_hosting         BOOLEAN DEFAULT FALSE        -- Datacenter bayrağı
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    INSERT INTO player_audit.login_sessions (
        session_token, player_id, ip_address, user_agent, device_fingerprint,
        country, country_code, continent, continent_code,
        region, region_name, city, district, zip,
        lat, lon, timezone, utc_offset, currency,
        isp, org, as_number, as_name, reverse_dns,
        is_mobile, is_proxy, is_hosting
    )
    VALUES (
        p_session_token, p_player_id, p_ip_address, p_user_agent, p_device_fingerprint,
        p_country, p_country_code, p_continent, p_continent_code,
        p_region, p_region_name, p_city, p_district, p_zip,
        p_lat, p_lon, p_timezone, p_utc_offset, p_currency,
        p_isp, p_org, p_as_number, p_as_name, p_reverse_dns,
        COALESCE(p_is_mobile, FALSE), COALESCE(p_is_proxy, FALSE), COALESCE(p_is_hosting, FALSE)
    )
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION player_audit.login_session_create IS 'Creates a new player login session with full GeoIP data. Returns session ID.';

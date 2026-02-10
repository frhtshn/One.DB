-- ================================================================
-- SESSION_SAVE: Yeni oturum kaydet veya güncelle
-- GeoIP bilgileri ip-api.com'dan çözümlenmiş olarak gelir
-- ================================================================

DROP FUNCTION IF EXISTS security.session_save(VARCHAR, BIGINT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, TIMESTAMPTZ);
DROP FUNCTION IF EXISTS security.session_save(VARCHAR, BIGINT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, TIMESTAMPTZ, CHAR, VARCHAR, VARCHAR, BOOLEAN, BOOLEAN, BOOLEAN);
DROP FUNCTION IF EXISTS security.session_save(VARCHAR, BIGINT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, TIMESTAMPTZ, VARCHAR, CHAR, VARCHAR, CHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, DECIMAL, DECIMAL, VARCHAR, INTEGER, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, BOOLEAN, BOOLEAN, BOOLEAN);

CREATE OR REPLACE FUNCTION security.session_save(
    p_session_id      VARCHAR(50),
    p_user_id         BIGINT,
    p_refresh_token_id VARCHAR(100),
    p_ip_address      VARCHAR(50),
    p_user_agent      VARCHAR(500),
    p_device_name     VARCHAR(100),
    p_expires_at      TIMESTAMPTZ,
    p_country         VARCHAR(100) DEFAULT NULL,        -- GeoIP ülke adı
    p_country_code    CHAR(2) DEFAULT NULL,             -- GeoIP ülke kodu
    p_continent       VARCHAR(100) DEFAULT NULL,        -- GeoIP kıta adı
    p_continent_code  CHAR(2) DEFAULT NULL,             -- GeoIP kıta kodu
    p_region          VARCHAR(100) DEFAULT NULL,        -- GeoIP bölge kısa kodu
    p_region_name     VARCHAR(200) DEFAULT NULL,        -- GeoIP bölge tam adı
    p_city            VARCHAR(200) DEFAULT NULL,        -- GeoIP şehir
    p_district        VARCHAR(200) DEFAULT NULL,        -- GeoIP ilçe/semt
    p_zip             VARCHAR(20) DEFAULT NULL,         -- GeoIP posta kodu
    p_lat             DECIMAL(9,6) DEFAULT NULL,        -- GeoIP enlem
    p_lon             DECIMAL(9,6) DEFAULT NULL,        -- GeoIP boylam
    p_timezone        VARCHAR(100) DEFAULT NULL,        -- GeoIP timezone
    p_utc_offset      INTEGER DEFAULT NULL,             -- GeoIP UTC offset (saniye)
    p_currency        VARCHAR(10) DEFAULT NULL,         -- GeoIP para birimi kodu
    p_isp             VARCHAR(300) DEFAULT NULL,        -- GeoIP ISP
    p_org             VARCHAR(300) DEFAULT NULL,        -- GeoIP organizasyon
    p_as_number       VARCHAR(200) DEFAULT NULL,        -- GeoIP AS numarası
    p_as_name         VARCHAR(300) DEFAULT NULL,        -- GeoIP AS organizasyon adı
    p_reverse_dns     VARCHAR(300) DEFAULT NULL,        -- GeoIP reverse DNS
    p_is_mobile       BOOLEAN DEFAULT FALSE,            -- Mobil bağlantı bayrağı
    p_is_proxy        BOOLEAN DEFAULT FALSE,            -- VPN/Proxy bayrağı
    p_is_hosting      BOOLEAN DEFAULT FALSE             -- Datacenter bayrağı
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO security.user_sessions (
        id, user_id, refresh_token_id, ip_address, user_agent, device_name, expires_at,
        country, country_code, continent, continent_code,
        region, region_name, city, district, zip,
        lat, lon, timezone, utc_offset, currency,
        isp, org, as_number, as_name, reverse_dns,
        is_mobile, is_proxy, is_hosting
    )
    VALUES (
        p_session_id, p_user_id, p_refresh_token_id, p_ip_address, p_user_agent, p_device_name, p_expires_at,
        p_country, p_country_code, p_continent, p_continent_code,
        p_region, p_region_name, p_city, p_district, p_zip,
        p_lat, p_lon, p_timezone, p_utc_offset, p_currency,
        p_isp, p_org, p_as_number, p_as_name, p_reverse_dns,
        COALESCE(p_is_mobile, FALSE), COALESCE(p_is_proxy, FALSE), COALESCE(p_is_hosting, FALSE)
    )
    ON CONFLICT (id) DO UPDATE
    SET
        refresh_token_id = EXCLUDED.refresh_token_id,
        last_activity_at = NOW(),
        ip_address       = EXCLUDED.ip_address,
        user_agent       = EXCLUDED.user_agent,
        country          = EXCLUDED.country,
        country_code     = EXCLUDED.country_code,
        continent        = EXCLUDED.continent,
        continent_code   = EXCLUDED.continent_code,
        region           = EXCLUDED.region,
        region_name      = EXCLUDED.region_name,
        city             = EXCLUDED.city,
        district         = EXCLUDED.district,
        zip              = EXCLUDED.zip,
        lat              = EXCLUDED.lat,
        lon              = EXCLUDED.lon,
        timezone         = EXCLUDED.timezone,
        utc_offset       = EXCLUDED.utc_offset,
        currency         = EXCLUDED.currency,
        isp              = EXCLUDED.isp,
        org              = EXCLUDED.org,
        as_number        = EXCLUDED.as_number,
        as_name          = EXCLUDED.as_name,
        reverse_dns      = EXCLUDED.reverse_dns,
        is_mobile        = EXCLUDED.is_mobile,
        is_proxy         = EXCLUDED.is_proxy,
        is_hosting       = EXCLUDED.is_hosting;
END;
$$;

COMMENT ON FUNCTION security.session_save IS 'Saves a new session or updates existing one with full GeoIP data';

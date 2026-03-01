-- ================================================================
-- AUTH_AUDIT_CREATE: Kimlik denetim log kaydı ekler
-- Bu fonksiyon bir kimlik denetim logu oluşturur ve BIGINT döner
-- GeoIP bilgileri ip-api.com'dan çözümlenmiş olarak gelir
-- Partitioned tablo: created_at üzerinden otomatik partition pruning
-- ================================================================

DROP FUNCTION IF EXISTS backoffice.auth_audit_create(BIGINT,BIGINT,BIGINT,VARCHAR,TEXT,VARCHAR,VARCHAR,VARCHAR,CHAR,VARCHAR,CHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,DECIMAL,DECIMAL,VARCHAR,INTEGER,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,BOOLEAN,BOOLEAN,BOOLEAN,BOOLEAN,VARCHAR);

CREATE OR REPLACE FUNCTION backoffice.auth_audit_create(
    p_user_id         BIGINT,
    p_company_id      BIGINT,
    p_tenant_id       BIGINT,
    p_event_type      VARCHAR(50),
    p_event_data      TEXT DEFAULT NULL,
    p_ip_address      VARCHAR(50) DEFAULT NULL,
    p_user_agent      VARCHAR(500) DEFAULT NULL,
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
    p_is_hosting      BOOLEAN DEFAULT FALSE,            -- Datacenter bayrağı
    p_success         BOOLEAN DEFAULT TRUE,
    p_error_message   VARCHAR(500) DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT; -- Oluşturulan kimlik denetim logunun ID'si
BEGIN
    INSERT INTO backoffice.auth_audit_log (
        user_id, company_id, tenant_id, event_type,
        event_data, ip_address, user_agent,
        country, country_code, continent, continent_code,
        region, region_name, city, district, zip,
        lat, lon, timezone, utc_offset, currency,
        isp, org, as_number, as_name, reverse_dns,
        is_mobile, is_proxy, is_hosting,
        success, error_message
    )
    VALUES (
        p_user_id, p_company_id, p_tenant_id, p_event_type,
        CASE WHEN p_event_data IS NOT NULL THEN p_event_data::JSONB ELSE NULL END,
        p_ip_address, p_user_agent,
        p_country, p_country_code, p_continent, p_continent_code,
        p_region, p_region_name, p_city, p_district, p_zip,
        p_lat, p_lon, p_timezone, p_utc_offset, p_currency,
        p_isp, p_org, p_as_number, p_as_name, p_reverse_dns,
        COALESCE(p_is_mobile, FALSE), COALESCE(p_is_proxy, FALSE), COALESCE(p_is_hosting, FALSE),
        p_success, p_error_message
    )
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION backoffice.auth_audit_create IS 'Adds an auth audit log entry with full GeoIP data. Returns BIGINT.';

-- ================================================================
-- IP_GEO_CACHE_UPSERT: IP geo cache kaydı ekle veya güncelle
-- ip-api.com'dan çözümlenen veriyi cache'e yazar
-- Mevcut kayıt varsa günceller, yoksa yeni ekler
-- ================================================================

DROP FUNCTION IF EXISTS catalog.ip_geo_cache_upsert(INET,VARCHAR,CHAR,VARCHAR,VARCHAR,VARCHAR,VARCHAR,DECIMAL,DECIMAL,VARCHAR,VARCHAR,VARCHAR,VARCHAR,BOOLEAN,BOOLEAN,BOOLEAN,INT);

CREATE OR REPLACE FUNCTION catalog.ip_geo_cache_upsert(
    p_ip_address    INET,               -- Sorgulanan IP adresi
    p_country       VARCHAR(100),        -- Ülke adı
    p_country_code  CHAR(2),             -- ISO ülke kodu
    p_region        VARCHAR(100),        -- Bölge kısa kodu
    p_region_name   VARCHAR(200),        -- Bölge tam adı
    p_city          VARCHAR(200),        -- Şehir
    p_zip           VARCHAR(20),         -- Posta kodu
    p_lat           DECIMAL(9,6),        -- Enlem
    p_lon           DECIMAL(9,6),        -- Boylam
    p_timezone      VARCHAR(100),        -- Timezone
    p_isp           VARCHAR(300),        -- ISP
    p_org           VARCHAR(300),        -- Organizasyon
    p_as_number     VARCHAR(200),        -- AS numarası
    p_is_mobile     BOOLEAN DEFAULT FALSE,   -- Mobil mi
    p_is_proxy      BOOLEAN DEFAULT FALSE,   -- Proxy/VPN mi
    p_is_hosting    BOOLEAN DEFAULT FALSE,   -- Hosting/DC mi
    p_ttl_days      INT DEFAULT 30           -- Cache süresi (gün)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO catalog.ip_geo_cache (
        ip_address, country, country_code, region, region_name,
        city, zip, lat, lon, timezone,
        isp, org, as_number, is_mobile, is_proxy, is_hosting,
        resolved_at, expires_at
    )
    VALUES (
        p_ip_address, p_country, p_country_code, p_region, p_region_name,
        p_city, p_zip, p_lat, p_lon, p_timezone,
        p_isp, p_org, p_as_number, COALESCE(p_is_mobile, FALSE), COALESCE(p_is_proxy, FALSE), COALESCE(p_is_hosting, FALSE),
        NOW(), NOW() + (p_ttl_days || ' days')::INTERVAL
    )
    ON CONFLICT (ip_address) DO UPDATE
    SET
        country       = EXCLUDED.country,
        country_code  = EXCLUDED.country_code,
        region        = EXCLUDED.region,
        region_name   = EXCLUDED.region_name,
        city          = EXCLUDED.city,
        zip           = EXCLUDED.zip,
        lat           = EXCLUDED.lat,
        lon           = EXCLUDED.lon,
        timezone      = EXCLUDED.timezone,
        isp           = EXCLUDED.isp,
        org           = EXCLUDED.org,
        as_number     = EXCLUDED.as_number,
        is_mobile     = EXCLUDED.is_mobile,
        is_proxy      = EXCLUDED.is_proxy,
        is_hosting    = EXCLUDED.is_hosting,
        resolved_at   = EXCLUDED.resolved_at,
        expires_at    = EXCLUDED.expires_at;
END;
$$;

COMMENT ON FUNCTION catalog.ip_geo_cache_upsert IS 'Upserts IP geolocation cache entry from ip-api.com resolution result.';

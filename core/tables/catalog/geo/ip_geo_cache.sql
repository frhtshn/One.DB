-- =============================================
-- Tablo: catalog.ip_geo_cache
-- Açıklama: IP adresi geo-lokasyon cache tablosu
-- ip-api.com'dan çözümlenen verilerin cache'i
-- Aynı IP için tekrar API çağrısı yapmayı önler
-- Backend akışı: cache kontrol → miss/expired → API → upsert
-- =============================================

DROP TABLE IF EXISTS catalog.ip_geo_cache CASCADE;

CREATE TABLE catalog.ip_geo_cache (
    ip_address       INET PRIMARY KEY,                          -- Sorgulanan IP adresi
    country          VARCHAR(100),                              -- Ülke adı
    country_code     CHAR(2),                                   -- ISO 3166-1 alpha-2 ülke kodu
    continent        VARCHAR(100),                              -- Kıta adı (ör: Europe, Asia)
    continent_code   CHAR(2),                                   -- Kıta kodu (ör: EU, AS)
    region           VARCHAR(100),                              -- Bölge/eyalet kısa kodu
    region_name      VARCHAR(200),                              -- Bölge/eyalet tam adı
    city             VARCHAR(200),                              -- Şehir
    district         VARCHAR(200),                              -- İlçe/semt
    zip              VARCHAR(20),                               -- Posta kodu
    lat              DECIMAL(9,6),                              -- Enlem
    lon              DECIMAL(9,6),                              -- Boylam
    timezone         VARCHAR(100),                              -- Timezone (ör: America/New_York)
    utc_offset       INTEGER,                                   -- UTC offset (saniye cinsinden)
    currency         VARCHAR(10),                               -- Ülke para birimi kodu (ör: USD, EUR)
    isp              VARCHAR(300),                              -- İnternet servis sağlayıcı
    org              VARCHAR(300),                              -- Organizasyon adı
    as_number        VARCHAR(200),                              -- AS numarası ve organizasyon
    as_name          VARCHAR(300),                              -- AS organizasyon adı
    reverse_dns      VARCHAR(300),                              -- Reverse DNS kaydı
    is_mobile        BOOLEAN NOT NULL DEFAULT FALSE,            -- Mobil bağlantı mı
    is_proxy         BOOLEAN NOT NULL DEFAULT FALSE,            -- Proxy/VPN/Tor mu
    is_hosting       BOOLEAN NOT NULL DEFAULT FALSE,            -- Hosting/datacenter mı
    resolved_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),        -- Son çözümleme zamanı
    expires_at       TIMESTAMPTZ NOT NULL DEFAULT NOW() + INTERVAL '30 days' -- Cache süresi dolumu
);

COMMENT ON TABLE catalog.ip_geo_cache IS 'IP geolocation cache from ip-api.com. TTL-based expiry to avoid redundant API calls.';

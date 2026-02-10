-- =============================================
-- Tablo: security.user_sessions
-- Açıklama: Aktif Oturumlar (Monthly Partitioned)
-- Kullanıcıların aktif oturum bilgilerini tutar
-- GeoIP bilgileri ip-api.com'dan çözümlenir
-- Partition: Monthly by created_at, 90 gün retention
-- =============================================

DROP TABLE IF EXISTS security.user_sessions CASCADE;

CREATE TABLE security.user_sessions (
    id VARCHAR(50) NOT NULL,                                  -- Oturum ID (Session ID)
    user_id BIGINT NOT NULL,                                  -- Kullanıcı ID (app-level ref: security.users)
    refresh_token_id VARCHAR(100) NOT NULL,                   -- Refresh token ID
    ip_address VARCHAR(50),                                   -- IP adresi
    user_agent VARCHAR(500),                                  -- User Agent
    device_name VARCHAR(100),                                 -- Cihaz adı
    country VARCHAR(100),                                     -- GeoIP ülke adı
    country_code CHAR(2),                                     -- GeoIP ülke kodu
    continent VARCHAR(100),                                   -- GeoIP kıta adı
    continent_code CHAR(2),                                   -- GeoIP kıta kodu
    region VARCHAR(100),                                      -- GeoIP bölge kısa kodu
    region_name VARCHAR(200),                                 -- GeoIP bölge tam adı
    city VARCHAR(200),                                        -- GeoIP şehir
    district VARCHAR(200),                                    -- GeoIP ilçe/semt
    zip VARCHAR(20),                                          -- GeoIP posta kodu
    lat DECIMAL(9,6),                                         -- GeoIP enlem
    lon DECIMAL(9,6),                                         -- GeoIP boylam
    timezone VARCHAR(100),                                    -- GeoIP timezone
    utc_offset INTEGER,                                       -- GeoIP UTC offset (saniye)
    currency VARCHAR(10),                                     -- GeoIP para birimi kodu
    isp VARCHAR(300),                                         -- GeoIP internet servis sağlayıcı
    org VARCHAR(300),                                         -- GeoIP organizasyon adı
    as_number VARCHAR(200),                                   -- GeoIP AS numarası
    as_name VARCHAR(300),                                     -- GeoIP AS organizasyon adı
    reverse_dns VARCHAR(300),                                 -- GeoIP reverse DNS
    is_mobile BOOLEAN NOT NULL DEFAULT FALSE,                 -- Mobil bağlantı bayrağı
    is_proxy BOOLEAN NOT NULL DEFAULT FALSE,                  -- VPN/Proxy bayrağı
    is_hosting BOOLEAN NOT NULL DEFAULT FALSE,                -- Datacenter bayrağı
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),            -- Oluşturulma zamanı
    last_activity_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),      -- Son aktivite zamanı
    expires_at TIMESTAMPTZ NOT NULL,                          -- Geçerlilik bitiş zamanı
    is_revoked BOOLEAN NOT NULL DEFAULT FALSE,                -- İptal edildi mi?
    revoked_at TIMESTAMPTZ,                                   -- İptal zamanı
    revoke_reason VARCHAR(200),                               -- İptal nedeni
    PRIMARY KEY (id, created_at)
) PARTITION BY RANGE (created_at);

-- Default partition (güvenlik ağı)
CREATE TABLE security.user_sessions_default PARTITION OF security.user_sessions DEFAULT;

COMMENT ON TABLE security.user_sessions IS 'Active user sessions tracking with GeoIP data. Monthly partitioned by created_at, 90-day retention.';

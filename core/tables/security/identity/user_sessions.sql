-- =============================================
-- Tablo: security.user_sessions
-- Açıklama: Aktif Oturumlar
-- Kullanıcıların aktif oturum bilgilerini tutar
-- GeoIP bilgileri ip-api.com'dan çözümlenir
-- =============================================

DROP TABLE IF EXISTS security.user_sessions CASCADE;

CREATE TABLE security.user_sessions (
    id VARCHAR(50) PRIMARY KEY,                            -- Oturum ID (Session ID)
    user_id BIGINT NOT NULL,                               -- Kullanıcı ID (FK: security.users)
    refresh_token_id VARCHAR(100) NOT NULL,                -- Refresh token ID
    ip_address VARCHAR(50),                                -- IP adresi
    user_agent VARCHAR(500),                               -- User Agent
    device_name VARCHAR(100),                              -- Cihaz adı
    country_code CHAR(2),                                  -- GeoIP ülke kodu
    region VARCHAR(100),                                   -- GeoIP bölge
    city VARCHAR(200),                                     -- GeoIP şehir
    is_proxy BOOLEAN NOT NULL DEFAULT FALSE,               -- VPN/Proxy bayrağı
    is_hosting BOOLEAN NOT NULL DEFAULT FALSE,             -- Datacenter bayrağı
    is_mobile BOOLEAN NOT NULL DEFAULT FALSE,              -- Mobil bağlantı bayrağı
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),         -- Oluşturulma zamanı
    last_activity_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),   -- Son aktivite zamanı
    expires_at TIMESTAMPTZ NOT NULL,                       -- Geçerlilik bitiş zamanı
    is_revoked BOOLEAN NOT NULL DEFAULT FALSE,             -- İptal edildi mi?
    revoked_at TIMESTAMPTZ,                                -- İptal zamanı
    revoke_reason VARCHAR(200)                             -- İptal nedeni
);

COMMENT ON TABLE security.user_sessions IS 'Active user sessions tracking with GeoIP data';

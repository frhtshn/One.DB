-- =============================================
-- Tablo: player_audit.login_sessions
-- Açıklama: Oyuncu oturum kayıtları
-- Başarılı girişler ve aktif oturumlar
-- Güvenlik, audit ve eşzamanlı oturum yönetimi için kritik
-- GeoIP bilgileri ip-api.com'dan çözümlenir
-- Aylık partition (created_at)
-- =============================================

DROP TABLE IF EXISTS player_audit.login_sessions CASCADE;

CREATE TABLE player_audit.login_sessions (
    id BIGSERIAL,                                              -- Benzersiz oturum kimliği
    session_token UUID NOT NULL,                               -- Oturum token'ı
    player_id BIGINT NOT NULL,                                 -- Player ID
    ip_address INET NOT NULL,                                  -- Giriş IP adresi
    user_agent VARCHAR(500),                                   -- Tarayıcı/cihaz bilgisi
    device_fingerprint VARCHAR(64),                            -- Cihaz parmak izi (hash)
    country_code CHAR(2),                                      -- GeoIP ülke kodu
    region VARCHAR(100),                                       -- GeoIP bölge
    city VARCHAR(200),                                         -- GeoIP şehir
    is_proxy BOOLEAN NOT NULL DEFAULT FALSE,                   -- VPN/Proxy bayrağı
    is_hosting BOOLEAN NOT NULL DEFAULT FALSE,                 -- Datacenter bayrağı
    is_mobile BOOLEAN NOT NULL DEFAULT FALSE,                  -- Mobil bağlantı bayrağı
    login_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),               -- Giriş zamanı
    last_activity_at TIMESTAMPTZ,                              -- Son aktivite zamanı
    logout_at TIMESTAMPTZ,                                     -- Çıkış zamanı (NULL = aktif)
    logout_type VARCHAR(20),                                   -- Çıkış tipi
    is_active BOOLEAN NOT NULL DEFAULT TRUE,                   -- Oturum aktif mi?
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),             -- Kayıt zamanı
    PRIMARY KEY (id, created_at)                               -- Partition key PK'ya dahil
) PARTITION BY RANGE (created_at);

CREATE TABLE player_audit.login_sessions_default PARTITION OF player_audit.login_sessions DEFAULT;

COMMENT ON TABLE player_audit.login_sessions IS 'Player session tracking for security audit and concurrent session management with GeoIP data. Partitioned monthly by created_at.';

-- =============================================
-- logout_type Değerleri:
--   MANUAL        : Kullanıcı çıkış yaptı
--   TIMEOUT       : Oturum zaman aşımı
--   FORCED        : Admin tarafından sonlandırıldı
--   TOKEN_EXPIRED : Token süresi doldu
-- =============================================

-- =============================================
-- Tablo: player_audit.login_attempts
-- Açıklama: Oyuncu giriş denemeleri
-- Başarılı ve başarısız tüm denemeler
-- Brute-force tespiti ve güvenlik analizi için kritik
-- GeoIP bilgileri ip-api.com'dan çözümlenir
-- Günlük partition (attempted_at)
-- =============================================

DROP TABLE IF EXISTS player_audit.login_attempts CASCADE;

CREATE TABLE player_audit.login_attempts (
    id BIGSERIAL,                                              -- Benzersiz kayıt kimliği
    player_id BIGINT,                                          -- Player ID (başarılıysa)
    identifier VARCHAR(300) NOT NULL,                          -- Denenen email/username (encrypted)
    ip_address INET NOT NULL,                                  -- IP adresi
    user_agent VARCHAR(500),                                   -- Tarayıcı/cihaz bilgisi
    country VARCHAR(100),                                      -- GeoIP ülke adı
    country_code CHAR(2),                                      -- GeoIP ülke kodu
    continent VARCHAR(100),                                    -- GeoIP kıta adı
    continent_code CHAR(2),                                    -- GeoIP kıta kodu
    region VARCHAR(100),                                       -- GeoIP bölge kısa kodu
    region_name VARCHAR(200),                                  -- GeoIP bölge tam adı
    city VARCHAR(200),                                         -- GeoIP şehir
    district VARCHAR(200),                                     -- GeoIP ilçe/semt
    zip VARCHAR(20),                                           -- GeoIP posta kodu
    lat DECIMAL(9,6),                                          -- GeoIP enlem
    lon DECIMAL(9,6),                                          -- GeoIP boylam
    timezone VARCHAR(100),                                     -- GeoIP timezone
    utc_offset INTEGER,                                        -- GeoIP UTC offset (saniye)
    currency VARCHAR(10),                                      -- GeoIP para birimi kodu
    isp VARCHAR(300),                                          -- GeoIP internet servis sağlayıcı
    org VARCHAR(300),                                          -- GeoIP organizasyon adı
    as_number VARCHAR(200),                                    -- GeoIP AS numarası
    as_name VARCHAR(300),                                      -- GeoIP AS organizasyon adı
    reverse_dns VARCHAR(300),                                  -- GeoIP reverse DNS
    is_mobile BOOLEAN NOT NULL DEFAULT FALSE,                  -- Mobil bağlantı bayrağı
    is_proxy BOOLEAN NOT NULL DEFAULT FALSE,                   -- VPN/Proxy bayrağı
    is_hosting BOOLEAN NOT NULL DEFAULT FALSE,                 -- Datacenter bayrağı
    is_successful BOOLEAN NOT NULL,                            -- Başarılı mı?
    failure_reason VARCHAR(50),                                -- Başarısızlık sebebi
    attempted_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),           -- Deneme zamanı
    PRIMARY KEY (id, attempted_at)                             -- Partition key PK'ya dahil
) PARTITION BY RANGE (attempted_at);

CREATE TABLE player_audit.login_attempts_default PARTITION OF player_audit.login_attempts DEFAULT;

COMMENT ON TABLE player_audit.login_attempts IS 'All player login attempts (successful and failed) for security monitoring and brute-force detection with GeoIP data. Partitioned daily by attempted_at.';

-- =============================================
-- failure_reason Değerleri:
--   INVALID_PASSWORD    : Yanlış şifre
--   PLAYER_NOT_FOUND    : Oyuncu bulunamadı
--   ACCOUNT_LOCKED      : Hesap kilitli
--   ACCOUNT_SUSPENDED   : Hesap askıya alınmış
--   ACCOUNT_CLOSED      : Hesap kapatılmış
--   2FA_FAILED          : İki faktörlü doğrulama başarısız
--   2FA_REQUIRED        : 2FA gerekli ama sağlanmadı
--   IP_BLOCKED          : IP adresi engelli
--   RATE_LIMITED        : Çok fazla deneme
-- =============================================

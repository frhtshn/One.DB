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
    country_code CHAR(2),                                      -- GeoIP ülke kodu
    city VARCHAR(200),                                         -- GeoIP şehir
    is_proxy BOOLEAN NOT NULL DEFAULT FALSE,                   -- VPN/Proxy bayrağı
    is_hosting BOOLEAN NOT NULL DEFAULT FALSE,                 -- Datacenter bayrağı
    is_mobile BOOLEAN NOT NULL DEFAULT FALSE,                  -- Mobil bağlantı bayrağı
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

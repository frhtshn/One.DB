-- =============================================
-- Tablo: affiliate_audit.login_attempts
-- Açıklama: Affiliate giriş denemeleri
-- Başarılı ve başarısız tüm denemeler
-- Brute-force tespiti için kritik
-- =============================================

DROP TABLE IF EXISTS affiliate_audit.login_attempts CASCADE;

CREATE TABLE affiliate_audit.login_attempts (
    id bigserial PRIMARY KEY,                              -- Benzersiz kayıt kimliği
    email varchar(150) NOT NULL,                           -- Denenen e-posta
    affiliate_id bigint,                                   -- Affiliate ID (başarılıysa)
    user_id bigint,                                        -- Kullanıcı ID (başarılıysa)
    ip_address inet NOT NULL,                              -- IP adresi
    user_agent varchar(500),                               -- Tarayıcı/cihaz bilgisi
    country_code char(2),                                  -- GeoIP ülke kodu
    is_successful boolean NOT NULL,                        -- Başarılı mı?
    failure_reason varchar(50),                            -- Başarısızlık sebebi: INVALID_PASSWORD, USER_NOT_FOUND, ACCOUNT_LOCKED, etc.
    attempted_at timestamp without time zone NOT NULL DEFAULT now() -- Deneme zamanı
);

COMMENT ON TABLE affiliate_audit.login_attempts IS 'All login attempts (successful and failed) for security monitoring and brute-force detection';

-- =============================================
-- Tablo: affiliate_audit.login_sessions
-- Açıklama: Affiliate kullanıcı oturum kayıtları
-- Başarılı girişler ve aktif oturumlar
-- Güvenlik ve audit için kritik
-- =============================================

DROP TABLE IF EXISTS affiliate_audit.login_sessions CASCADE;

CREATE TABLE affiliate_audit.login_sessions (
    id bigserial PRIMARY KEY,                              -- Benzersiz oturum kimliği
    session_token uuid NOT NULL,                           -- Oturum token'ı
    affiliate_id bigint NOT NULL,                          -- Affiliate ID
    user_id bigint NOT NULL,                               -- Kullanıcı ID
    ip_address inet NOT NULL,                              -- Giriş IP adresi
    user_agent varchar(500),                               -- Tarayıcı/cihaz bilgisi
    device_fingerprint varchar(64),                        -- Cihaz parmak izi (hash)
    country_code char(2),                                  -- GeoIP ülke kodu
    city varchar(100),                                     -- GeoIP şehir
    login_at timestamp without time zone NOT NULL DEFAULT now(), -- Giriş zamanı
    last_activity_at timestamp without time zone,          -- Son aktivite zamanı
    logout_at timestamp without time zone,                 -- Çıkış zamanı (NULL = aktif)
    logout_type varchar(20),                               -- Çıkış tipi: MANUAL, TIMEOUT, FORCED, TOKEN_EXPIRED
    is_active boolean NOT NULL DEFAULT true,               -- Oturum aktif mi?
    created_at timestamp without time zone NOT NULL DEFAULT now()
);

COMMENT ON TABLE affiliate_audit.login_sessions IS 'Affiliate user session tracking for security audit and concurrent session management';

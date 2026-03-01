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
    country varchar(100),                                  -- GeoIP ülke adı
    country_code char(2),                                  -- GeoIP ülke kodu
    continent varchar(100),                                -- GeoIP kıta adı
    continent_code char(2),                                -- GeoIP kıta kodu
    region varchar(100),                                   -- GeoIP bölge kısa kodu
    region_name varchar(200),                              -- GeoIP bölge tam adı
    city varchar(200),                                     -- GeoIP şehir
    district varchar(200),                                 -- GeoIP ilçe/semt
    zip varchar(20),                                       -- GeoIP posta kodu
    lat decimal(9,6),                                      -- GeoIP enlem
    lon decimal(9,6),                                      -- GeoIP boylam
    timezone varchar(100),                                 -- GeoIP timezone
    utc_offset integer,                                    -- GeoIP UTC offset (saniye)
    currency varchar(10),                                  -- GeoIP para birimi kodu
    isp varchar(300),                                      -- GeoIP internet servis sağlayıcı
    org varchar(300),                                      -- GeoIP organizasyon adı
    as_number varchar(200),                                -- GeoIP AS numarası
    as_name varchar(300),                                  -- GeoIP AS organizasyon adı
    reverse_dns varchar(300),                              -- GeoIP reverse DNS
    is_mobile boolean NOT NULL DEFAULT false,              -- Mobil bağlantı bayrağı
    is_proxy boolean NOT NULL DEFAULT false,               -- VPN/Proxy bayrağı
    is_hosting boolean NOT NULL DEFAULT false,             -- Datacenter bayrağı
    login_at timestamp without time zone NOT NULL DEFAULT now(), -- Giriş zamanı
    last_activity_at timestamp without time zone,          -- Son aktivite zamanı
    logout_at timestamp without time zone,                 -- Çıkış zamanı (NULL = aktif)
    logout_type varchar(20),                               -- Çıkış tipi: MANUAL, TIMEOUT, FORCED, TOKEN_EXPIRED
    is_active boolean NOT NULL DEFAULT true,               -- Oturum aktif mi?
    created_at timestamp without time zone NOT NULL DEFAULT now()
);

COMMENT ON TABLE affiliate_audit.login_sessions IS 'Affiliate user session tracking for security audit and concurrent session management';

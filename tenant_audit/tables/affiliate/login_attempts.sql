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
    is_successful boolean NOT NULL,                        -- Başarılı mı?
    failure_reason varchar(50),                            -- Başarısızlık sebebi: INVALID_PASSWORD, USER_NOT_FOUND, ACCOUNT_LOCKED, etc.
    attempted_at timestamp without time zone NOT NULL DEFAULT now() -- Deneme zamanı
);

COMMENT ON TABLE affiliate_audit.login_attempts IS 'All login attempts (successful and failed) for security monitoring and brute-force detection';

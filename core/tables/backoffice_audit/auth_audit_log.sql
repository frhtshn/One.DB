-- =============================================
-- Tablo: backoffice.auth_audit_log
-- Açıklama: Güvenlik olay kayıtları
-- Giriş, çıkış, şifre değişikliği gibi işlemleri tutar
-- GeoIP bilgileri ip-api.com'dan çözümlenir
-- Günlük partition (created_at) - retention: 90 gün
-- =============================================

DROP TABLE IF EXISTS backoffice.auth_audit_log CASCADE;

CREATE TABLE backoffice.auth_audit_log (
    id BIGSERIAL,                                             -- Kaydın benzersiz kimliği
    user_id BIGINT,                                           -- Kullanıcı kimliği
    company_id BIGINT,                                        -- Şirket kimliği
    tenant_id BIGINT,                                         -- Kiracı kimliği
    event_type VARCHAR(50) NOT NULL,                          -- Gerçekleşen güvenlik olayının türü
    event_data JSONB,                                         -- Olay ile ilgili ek veriler
    ip_address VARCHAR(50),                                   -- İşlemin yapıldığı IP adresi
    user_agent VARCHAR(500),                                  -- Kullanıcının tarayıcı/cihaz bilgisi
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
    success BOOLEAN NOT NULL DEFAULT TRUE,                    -- İşlemin başarılı olup olmadığı
    error_message VARCHAR(500),                               -- Hata durumunda hata mesajı
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),            -- Kaydın oluşturulma zamanı (partition key)
    PRIMARY KEY (id, created_at)                              -- Composite PK: partition zorunluluğu
) PARTITION BY RANGE (created_at);

-- Güvenlik ağı: Eşleşmeyen kayıtlar buraya düşer
CREATE TABLE backoffice.auth_audit_log_default PARTITION OF backoffice.auth_audit_log DEFAULT;

COMMENT ON TABLE backoffice.auth_audit_log IS 'Stores security-related events such as login, logout, and password changes with GeoIP data. Partitioned daily by created_at. Retention: 90 days.';

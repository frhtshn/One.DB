-- =============================================
-- Tablo: backoffice.auth_audit_log
-- Açıklama: Güvenlik olay kayıtları
-- Giriş, çıkış, şifre değişikliği gibi işlemleri tutar
-- GeoIP bilgileri ip-api.com'dan çözümlenir
-- =============================================

DROP TABLE IF EXISTS backoffice.auth_audit_log CASCADE;

CREATE TABLE IF NOT EXISTS backoffice.auth_audit_log (
    id BIGSERIAL PRIMARY KEY,                              -- Kaydın benzersiz kimliği
    user_id BIGINT,                                        -- Kullanıcı kimliği
    company_id BIGINT,                                     -- Şirket kimliği
    tenant_id BIGINT,                                      -- Kiracı kimliği
    event_type VARCHAR(50) NOT NULL,                       -- Gerçekleşen güvenlik olayının türü
    event_data JSONB,                                      -- Olay ile ilgili ek veriler
    ip_address VARCHAR(50),                                -- İşlemin yapıldığı IP adresi
    user_agent VARCHAR(500),                               -- Kullanıcının tarayıcı/cihaz bilgisi
    country_code CHAR(2),                                  -- GeoIP ülke kodu
    city VARCHAR(200),                                     -- GeoIP şehir
    is_proxy BOOLEAN NOT NULL DEFAULT FALSE,               -- VPN/Proxy bayrağı
    is_hosting BOOLEAN NOT NULL DEFAULT FALSE,             -- Datacenter bayrağı
    is_mobile BOOLEAN NOT NULL DEFAULT FALSE,              -- Mobil bağlantı bayrağı
    success BOOLEAN NOT NULL DEFAULT TRUE,                 -- İşlemin başarılı olup olmadığı
    error_message VARCHAR(500),                            -- Hata durumunda hata mesajı
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()          -- Kaydın oluşturulma zamanı
);

COMMENT ON TABLE backoffice.auth_audit_log IS 'Stores security-related events such as login, logout, and password changes with GeoIP data. Used by AuthAuditDataService and AuthAuditConsumer.';

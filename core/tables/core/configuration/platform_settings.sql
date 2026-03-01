-- =============================================
-- Tablo: core.platform_settings
-- Açıklama: Platform seviyesi dış servis ayarları
-- ip-api, currencylayer, SMTP, AWS SES gibi
-- Sortis One'ın kullandığı harici API yapılandırmaları
-- Config değerleri uygulama katmanında şifreli tutulur
-- =============================================

DROP TABLE IF EXISTS core.platform_settings CASCADE;

CREATE TABLE core.platform_settings (
    id bigserial PRIMARY KEY,                              -- Benzersiz kayıt kimliği
    category varchar(50) NOT NULL DEFAULT 'General',       -- Ayar kategorisi: EMAIL, GEO_LOCATION, EXCHANGE_RATE, CLOUD
    setting_key varchar(50) NOT NULL,                      -- Ayar anahtarı: smtp, aws_ses, ip_api, currencylayer
    setting_value text NOT NULL,                           -- Şifreli ayar değeri (uygulama katmanında encrypt/decrypt)
    environment varchar(20) NOT NULL DEFAULT 'production', -- Ortam: production, staging
    is_active boolean NOT NULL DEFAULT true,               -- Aktif/pasif durumu
    description varchar(255),                              -- Servis açıklaması
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now()  -- Son güncelleme zamanı
);

COMMENT ON TABLE core.platform_settings IS 'Platform-level external service configurations such as ip-api, currencylayer, SMTP and AWS SES. Config values are encrypted at application layer';

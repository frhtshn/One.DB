-- =============================================
-- Tablo: catalog.provider_settings
-- Açıklama: Provider yapılandırma ayarları
-- Her provider için key-value formatında ayarlar
-- Örnek: api_url, timeout, retry_count
-- =============================================

DROP TABLE IF EXISTS catalog.provider_settings CASCADE;

CREATE TABLE catalog.provider_settings (
    id bigserial PRIMARY KEY,                              -- Benzersiz ayar kimliği
    provider_id bigint NOT NULL,                           -- Provider ID (FK: catalog.providers)
    setting_key varchar(100) NOT NULL,                     -- Ayar anahtarı: api_url, timeout, retry_count
    setting_value jsonb NOT NULL,                          -- Ayar değeri (JSON formatında)
    description varchar(255),                              -- Ayar açıklaması
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now()  -- Son güncelleme zamanı
);

COMMENT ON TABLE catalog.provider_settings IS 'Provider configuration settings stored as key-value pairs such as api_url, timeout, retry_count';

-- =============================================
-- Tablo: core.client_settings
-- Açıklama: Client yapılandırma ayarları tablosu
-- Her client için key-value formatında özel ayarlar
-- Örnek: max_withdrawal_daily, kyc_required_level
-- =============================================

DROP TABLE IF EXISTS core.client_settings CASCADE;

CREATE TABLE core.client_settings (
    id bigserial PRIMARY KEY,                              -- Benzersiz ayar kimliği
    client_id bigint NOT NULL,                             -- Client ID (FK: core.clients)
    category varchar(50) NOT NULL DEFAULT 'General',       -- Ayar kategorisi: System, Mail, Payment
    setting_key varchar(100) NOT NULL,                     -- Ayar anahtarı: max_withdrawal_daily
    setting_value jsonb NOT NULL,                          -- Ayar değeri (JSON formatında)
    description varchar(255),                              -- Ayar açıklaması
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now() -- Son güncelleme zamanı


);

COMMENT ON TABLE core.client_settings IS 'Client-specific configuration settings stored as key-value pairs such as withdrawal limits and KYC requirements';

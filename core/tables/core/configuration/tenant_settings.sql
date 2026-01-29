-- =============================================
-- Tablo: core.tenant_settings
-- Açıklama: Tenant yapılandırma ayarları tablosu
-- Her tenant için key-value formatında özel ayarlar
-- Örnek: max_withdrawal_daily, kyc_required_level
-- =============================================

DROP TABLE IF EXISTS core.tenant_settings CASCADE;

CREATE TABLE core.tenant_settings (
    id bigserial PRIMARY KEY,                              -- Benzersiz ayar kimliği
    tenant_id bigint NOT NULL,                             -- Tenant ID (FK: core.tenants)
    category varchar(50) NOT NULL DEFAULT 'General',       -- Ayar kategorisi: System, Mail, Payment
    setting_key varchar(100) NOT NULL,                     -- Ayar anahtarı: max_withdrawal_daily
    setting_value jsonb NOT NULL,                          -- Ayar değeri (JSON formatında)
    description varchar(255),                              -- Ayar açıklaması
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now(), -- Son güncelleme zamanı

    UNIQUE(tenant_id, setting_key)                         -- Tenant bazında key unique olmalı
);

COMMENT ON TABLE core.tenant_settings IS 'Tenant-specific configuration settings stored as key-value pairs such as withdrawal limits and KYC requirements';

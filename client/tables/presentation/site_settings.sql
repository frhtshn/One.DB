-- =============================================
-- Tablo: presentation.site_settings
-- Açıklama: Site geneli ayarlar (tek satır)
-- İletişim bilgileri, analitik, çerez onayı,
-- yaş kapısı ve canlı sohbet entegrasyon ayarları
-- =============================================

DROP TABLE IF EXISTS presentation.site_settings CASCADE;

CREATE TABLE presentation.site_settings (
    id                   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_name         VARCHAR(200),                              -- Yasal şirket adı
    company_reg_number   VARCHAR(100),                              -- Şirket tescil numarası
    contact_email        VARCHAR(200),                              -- Genel iletişim e-postası
    contact_phone        VARCHAR(50),                               -- Telefon numarası (E.164 formatı)
    contact_address      JSONB,                                     -- Çok dilli adres: {"en": "...", "tr": "..."}
    analytics_config     JSONB NOT NULL DEFAULT '{}',              -- {"ga4_id": "G-...", "gtm_id": "GTM-...", "fb_pixel_id": "..."}
    cookie_consent_config JSONB NOT NULL DEFAULT '{}',             -- {"provider": "cookiebot", "script_id": "...", "mode": "explicit"}
    age_gate_config      JSONB NOT NULL DEFAULT '{"min_age": 18}', -- {"min_age": 18, "method": "modal", "jurisdictions": ["TR"]}
    live_chat_provider   VARCHAR(50),                               -- intercom, tawk, zendesk, crisp, custom
    live_chat_config     JSONB NOT NULL DEFAULT '{}',              -- Sağlayıcıya göre yapılandırma
    created_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at           TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by           BIGINT,
    updated_by           BIGINT
);

COMMENT ON TABLE presentation.site_settings IS 'Global site settings per tenant (single row). Stores contact info, analytics IDs (GA4, GTM, FB Pixel), cookie consent configuration, age gate settings, and live chat provider config. Cached at application startup.';

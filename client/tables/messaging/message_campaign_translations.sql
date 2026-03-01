-- =============================================
-- Tablo: messaging.message_campaign_translations
-- Kampanya mesaj içeriğinin dil bazlı çevirileri
-- Şablonsuz kampanyalar için doğrudan içerik tanımlanır
-- =============================================

DROP TABLE IF EXISTS messaging.message_campaign_translations CASCADE;

CREATE TABLE messaging.message_campaign_translations (
    id SERIAL PRIMARY KEY,
    campaign_id INTEGER NOT NULL,                 -- Bağlı kampanya
    language_code CHAR(2) NOT NULL,               -- Dil kodu: en, tr, de

    -- İçerik
    subject VARCHAR(500),                         -- Konu satırı (email için)
    body TEXT NOT NULL,                            -- Mesaj içeriği (HTML destekli)
    preview_text VARCHAR(255),                    -- Ön izleme metni (email için)

    -- Audit
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);

COMMENT ON TABLE messaging.message_campaign_translations IS 'Multilingual campaign message content per language, used when campaign does not use a template';

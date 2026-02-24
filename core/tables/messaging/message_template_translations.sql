-- =============================================
-- Tablo: messaging.message_template_translations
-- Açıklama: Platform mesaj şablonları çeviri tablosu
-- Her şablon için dil bazlı içerik
-- Email: subject + body_html + body_text + preview_text
-- SMS: body_text (diğerleri NULL)
-- =============================================

DROP TABLE IF EXISTS messaging.message_template_translations CASCADE;

CREATE TABLE messaging.message_template_translations (
    id SERIAL PRIMARY KEY,
    template_id INTEGER NOT NULL,                     -- Bağlı şablon (FK → message_templates)
    language_code CHAR(2) NOT NULL,                   -- Dil kodu: en, tr, de

    -- İçerik (kanal bazlı kullanım)
    subject VARCHAR(500),                             -- Email konusu (email: zorunlu, sms: NULL)
    body_html TEXT,                                   -- HTML gövde (email: zorunlu, sms: NULL)
    body_text TEXT NOT NULL,                           -- Düz metin (email: fallback, sms: ana içerik)
    preview_text VARCHAR(255),                        -- Email ön izleme (sms: NULL)

    -- Audit
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_by BIGINT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_by BIGINT
);

COMMENT ON TABLE messaging.message_template_translations IS 'Multilingual content for platform message templates. Subject and body_html used for email channel, body_text for SMS.';

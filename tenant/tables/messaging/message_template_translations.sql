-- =============================================
-- Tablo: messaging.message_template_translations
-- Mesaj şablonlarının dil bazlı çeviri içerikleri
-- Her şablon için farklı dil desteği
-- Email: subject + body_html + body_text + preview_text
-- SMS: body_text (diğerleri NULL)
-- Campaign: body (eski uyumluluk, body_html ile aynı)
-- =============================================

DROP TABLE IF EXISTS messaging.message_template_translations CASCADE;

CREATE TABLE messaging.message_template_translations (
    id SERIAL PRIMARY KEY,
    template_id INTEGER NOT NULL,                 -- Bağlı şablon
    language_code CHAR(2) NOT NULL,               -- Dil kodu: en, tr, de

    -- İçerik (kanal bazlı kullanım)
    subject VARCHAR(500),                         -- Konu satırı (email kanalı için)
    body_html TEXT,                               -- HTML gövde (email: zorunlu, sms: NULL)
    body_text TEXT,                               -- Düz metin (email: fallback, sms: ana içerik)
    preview_text VARCHAR(255),                    -- Ön izleme metni (email için)

    -- Audit
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);

COMMENT ON TABLE messaging.message_template_translations IS 'Multilingual template content including subject, body_html, body_text, and preview text per language. Supports email and SMS channels.';

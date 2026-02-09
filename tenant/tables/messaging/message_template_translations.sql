-- =============================================
-- Tablo: messaging.message_template_translations
-- Mesaj şablonlarının dil bazlı çeviri içerikleri
-- Her şablon için farklı dil desteği
-- =============================================

DROP TABLE IF EXISTS messaging.message_template_translations CASCADE;

CREATE TABLE messaging.message_template_translations (
    id SERIAL PRIMARY KEY,
    template_id INTEGER NOT NULL,                 -- Bağlı şablon
    language_code CHAR(2) NOT NULL,               -- Dil kodu: en, tr, de

    -- İçerik
    subject VARCHAR(500),                         -- Konu satırı (email kanalı için)
    body TEXT NOT NULL,                            -- Mesaj içeriği (HTML destekli)
    preview_text VARCHAR(255),                    -- Ön izleme metni (email için)

    -- Audit
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);

COMMENT ON TABLE messaging.message_template_translations IS 'Multilingual template content including subject, body, and preview text per language';

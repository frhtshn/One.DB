-- =============================================
-- Slide Category Translations (Kategori Çevirileri)
-- Slide kategorilerinin çok dilli içerikleri
-- =============================================

DROP TABLE IF EXISTS content.slide_category_translations CASCADE;

CREATE TABLE content.slide_category_translations (
    id SERIAL PRIMARY KEY,
    category_id INTEGER NOT NULL,                 -- Bağlı kategori
    language_code CHAR(2) NOT NULL,               -- Dil kodu: en, tr, de
    name VARCHAR(100) NOT NULL,                   -- Kategori adı
    description VARCHAR(500),                     -- Kategori açıklaması
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER


);

COMMENT ON TABLE content.slide_category_translations IS 'Multilingual translations for slide categories';

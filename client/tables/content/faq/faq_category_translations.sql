-- =============================================
-- FAQ Category Translations (SSS Kategori Çevirileri)
-- SSS kategorilerinin dil bazlı isimleri
-- =============================================

DROP TABLE IF EXISTS content.faq_category_translations CASCADE;

CREATE TABLE content.faq_category_translations (
    id SERIAL PRIMARY KEY,
    category_id INTEGER NOT NULL,                 -- Kategori ID
    language_code CHAR(2) NOT NULL,               -- Dil kodu: en, tr, de
    name VARCHAR(100) NOT NULL,                   -- Kategori adı
    description TEXT,                             -- Açıklama
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);

COMMENT ON TABLE content.faq_category_translations IS 'Multilingual translations for FAQ category names and descriptions';

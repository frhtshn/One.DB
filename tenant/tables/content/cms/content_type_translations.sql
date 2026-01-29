-- =============================================
-- Content Type Translations (Tür Çevirileri)
-- İçerik türlerinin (örn: Makale, Haber) çevirileri
-- =============================================

DROP TABLE IF EXISTS content.content_type_translations CASCADE;

CREATE TABLE content.content_type_translations (
    id SERIAL PRIMARY KEY,
    content_type_id INTEGER NOT NULL,             -- İçerik türü ID
    language_id INTEGER NOT NULL,                 -- Dil ID
    name VARCHAR(100) NOT NULL,                   -- Tür adı
    description TEXT,                             -- Tür açıklaması
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);

COMMENT ON TABLE content.content_type_translations IS 'Multilingual translations for content type names and descriptions';

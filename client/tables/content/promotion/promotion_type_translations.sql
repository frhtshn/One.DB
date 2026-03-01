-- =============================================
-- Promotion Type Translations (Promosyon Türü Çevirileri)
-- =============================================

DROP TABLE IF EXISTS content.promotion_type_translations CASCADE;

CREATE TABLE content.promotion_type_translations (
    id SERIAL PRIMARY KEY,
    promotion_type_id INTEGER NOT NULL,           -- Bağlı promosyon türü
    language_code CHAR(2) NOT NULL,               -- Dil kodu
    name VARCHAR(100) NOT NULL,                   -- Tür adı
    description VARCHAR(500),                     -- Açıklama
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);

COMMENT ON TABLE content.promotion_type_translations IS 'Multilingual translations for promotion types';

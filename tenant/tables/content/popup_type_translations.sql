-- =============================================
-- Popup Type Translations (Popup Türü Çevirileri)
-- =============================================

DROP TABLE IF EXISTS content.popup_type_translations CASCADE;

CREATE TABLE content.popup_type_translations (
    id SERIAL PRIMARY KEY,
    popup_type_id INTEGER NOT NULL,               -- Bağlı popup türü
    language_code CHAR(2) NOT NULL,               -- Dil kodu
    name VARCHAR(100) NOT NULL,                   -- Tür adı
    description VARCHAR(500),                     -- Açıklama
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,

    CONSTRAINT uq_popup_type_trans_lang UNIQUE (popup_type_id, language_code)
);

COMMENT ON TABLE content.popup_type_translations IS 'Multilingual translations for popup types';

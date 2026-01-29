-- =============================================
-- FAQ Item Translations (SSS Soru Çevirileri)
-- Soru ve cevapların dil bazlı çevirileri
-- =============================================

DROP TABLE IF EXISTS content.faq_item_translations CASCADE;

CREATE TABLE content.faq_item_translations (
    id SERIAL PRIMARY KEY,
    faq_item_id INTEGER NOT NULL,                 -- Soru ID
    language_id INTEGER NOT NULL,                 -- Dil ID
    question TEXT NOT NULL,                       -- Soru metni
    answer TEXT NOT NULL,                         -- Cevap metni
    status VARCHAR(20) NOT NULL DEFAULT 'draft',  -- Durum
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);

COMMENT ON TABLE content.faq_item_translations IS 'Multilingual FAQ question and answer translations';

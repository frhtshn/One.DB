-- =============================================
-- Content Translations (İçerik Çevirileri)
-- CMS içeriklerinin dil bazlı çevirileri
-- SEO ve meta verileri içerir
-- =============================================

DROP TABLE IF EXISTS content.content_translations CASCADE;

CREATE TABLE content.content_translations (
    id SERIAL PRIMARY KEY,
    content_id INTEGER NOT NULL,                  -- İçerik ID
    language_id INTEGER NOT NULL,                 -- Dil ID
    title VARCHAR(255) NOT NULL,                  -- Başlık
    subtitle VARCHAR(500),                        -- Alt başlık
    summary TEXT,                                 -- Özet
    body TEXT,                                    -- İçerik metni (HTML)
    meta_title VARCHAR(255),                      -- SEO Başlık
    meta_description VARCHAR(500),                -- SEO Açıklama
    meta_keywords VARCHAR(500),                   -- SEO Anahtar Kelimeler
    status VARCHAR(20) NOT NULL DEFAULT 'draft',  -- Çeviri durumu
    translated_at TIMESTAMP WITHOUT TIME ZONE,    -- Çevrilme tarihi
    translated_by INTEGER,                        -- Çeviren kişi
    reviewed_at TIMESTAMP WITHOUT TIME ZONE,      -- Onaylanma tarihi
    reviewed_by INTEGER,                          -- Onaylayan kişi
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);

COMMENT ON TABLE content.content_translations IS 'Multilingual content translations with title, body, and SEO metadata per language';

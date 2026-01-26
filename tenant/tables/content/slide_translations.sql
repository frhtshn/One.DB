-- =============================================
-- Slide Translations (Slide Çevirileri)
-- Slide'ların çok dilli metin içerikleri
-- Her dil için ayrı başlık, açıklama ve CTA
-- =============================================

DROP TABLE IF EXISTS content.slide_translations CASCADE;

CREATE TABLE content.slide_translations (
    id SERIAL PRIMARY KEY,
    slide_id INTEGER NOT NULL,                    -- Bağlı slide
    language_code CHAR(2) NOT NULL,               -- Dil kodu: en, tr, de

    -- Metin İçerikleri
    title VARCHAR(200),                           -- Ana başlık
    subtitle VARCHAR(300),                        -- Alt başlık
    description TEXT,                             -- Açıklama metni

    -- Call to Action
    cta_text VARCHAR(50),                         -- Buton metni: "Hemen Oyna", "Detaylar"
    cta_secondary_text VARCHAR(50),               -- İkincil buton metni (varsa)

    -- SEO
    alt_text VARCHAR(255),                        -- Görsel alt metni (erişilebilirlik)

    -- Audit
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER,

    CONSTRAINT uq_slide_translation_lang UNIQUE (slide_id, language_code)
);

COMMENT ON TABLE content.slide_translations IS 'Multilingual text content for slides including titles, descriptions, and CTAs';

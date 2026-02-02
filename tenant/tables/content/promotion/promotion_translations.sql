-- =============================================
-- Promotion Translations (Promosyon Çevirileri)
-- Her promosyonun farklı dillerdeki içerikleri
-- Başlık, açıklama, şartlar ve CTA bilgileri
-- =============================================

DROP TABLE IF EXISTS content.promotion_translations CASCADE;

CREATE TABLE content.promotion_translations (
    id SERIAL PRIMARY KEY,
    promotion_id INTEGER NOT NULL,                -- Bağlı promosyon
    language_code CHAR(2) NOT NULL,               -- Dil kodu: en, tr, de
    title VARCHAR(255) NOT NULL,                  -- Promosyon başlığı
    subtitle VARCHAR(500),                        -- Alt başlık
    summary TEXT,                                 -- Kısa özet (liste görünümü için)
    description TEXT,                             -- Detaylı açıklama (HTML destekli)
    terms_conditions TEXT,                        -- Şartlar ve koşullar
    cta_text VARCHAR(100),                        -- Buton metni ("Hemen Katıl", "Bonus Al")
    cta_url VARCHAR(500),                         -- Buton linki (/deposit, /register)
    meta_title VARCHAR(255),                      -- SEO sayfa başlığı
    meta_description VARCHAR(500),                -- SEO açıklaması
    status VARCHAR(20) NOT NULL DEFAULT 'draft',  -- Çeviri durumu: draft, published
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);

COMMENT ON TABLE content.promotion_translations IS 'Multilingual promotion content including titles, descriptions, terms, and CTA elements';

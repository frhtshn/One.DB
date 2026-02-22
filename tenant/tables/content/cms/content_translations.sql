-- =============================================
-- Content Translations (İçerik Çevirileri)
-- CMS içeriklerinin dil bazlı çevirileri
-- SEO, Open Graph ve Twitter Card meta verileri içerir
-- =============================================

DROP TABLE IF EXISTS content.content_translations CASCADE;

CREATE TABLE content.content_translations (
    id SERIAL PRIMARY KEY,
    content_id INTEGER NOT NULL,                  -- İçerik ID
    language_code CHAR(2) NOT NULL,               -- Dil kodu: en, tr, de
    title VARCHAR(255) NOT NULL,                  -- Başlık
    subtitle VARCHAR(500),                        -- Alt başlık
    summary TEXT,                                 -- Özet
    body TEXT,                                    -- İçerik metni (HTML)
    meta_title VARCHAR(255),                      -- SEO Başlık
    meta_description VARCHAR(500),                -- SEO Açıklama
    meta_keywords VARCHAR(500),                   -- SEO Anahtar Kelimeler
    -- Open Graph alanları
    og_title VARCHAR(200),                        -- Open Graph başlık (boşsa title kullanılır)
    og_description VARCHAR(500),                  -- Open Graph açıklama
    og_image_url VARCHAR(500),                    -- Open Graph görsel URL
    -- Twitter Card alanları
    twitter_card VARCHAR(30),                     -- summary veya summary_large_image
    twitter_title VARCHAR(200),                   -- Twitter başlık (boşsa og_title sonra title)
    twitter_description VARCHAR(500),             -- Twitter açıklama
    twitter_image_url VARCHAR(500),               -- Twitter kart görseli
    -- Robots & Canonical
    robots_directive VARCHAR(100),                -- index,follow / noindex,nofollow vb. NULL = index,follow varsayımı
    canonical_url VARCHAR(500),                   -- Kanonik URL geçersiz kılma (NULL = otomatik hesaplanır)
    -- Durum alanları
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

COMMENT ON TABLE content.content_translations IS 'Multilingual content translations with title, body, SEO metadata, Open Graph and Twitter Card fields, and robots directives per language.';

COMMENT ON COLUMN content.content_translations.og_title IS 'Open Graph title for social sharing. Falls back to title if null.';
COMMENT ON COLUMN content.content_translations.robots_directive IS 'Robots meta directive e.g. index,follow or noindex,nofollow';
COMMENT ON COLUMN content.content_translations.canonical_url IS 'Override canonical URL. Auto-generated from slug if null.';

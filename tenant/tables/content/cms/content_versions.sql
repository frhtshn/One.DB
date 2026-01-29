-- =============================================
-- Content Versions (İçerik Versiyonları)
-- İçerik değişikliklerinin tarihçesi
-- Geri alma ve audit işlemleri için kullanılır
-- =============================================

DROP TABLE IF EXISTS content.content_versions CASCADE;

CREATE TABLE content.content_versions (
    id SERIAL PRIMARY KEY,
    content_id INTEGER NOT NULL,                  -- İçerik ID
    language_id INTEGER NOT NULL,                 -- Dil ID
    version INTEGER NOT NULL,                     -- Versiyon numarası
    title VARCHAR(255) NOT NULL,                  -- Başlık
    subtitle VARCHAR(500),                        -- Alt başlık
    summary TEXT,                                 -- Özet
    body TEXT,                                    -- İçerik
    meta_title VARCHAR(255),                      -- SEO Başlık
    meta_description VARCHAR(500),                -- SEO Açıklama
    meta_keywords VARCHAR(500),                   -- SEO Anahtar Kelimeler
    change_note TEXT,                             -- Değişiklik notu
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER
);

COMMENT ON TABLE content.content_versions IS 'Content version history for auditing and rollback capabilities with change notes';

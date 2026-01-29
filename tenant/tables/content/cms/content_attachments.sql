-- =============================================
-- Content Attachments (İçerik Dosyaları)
-- İçeriklere eklenen dosyalar (görsel, döküman vb.)
-- Galeri ve indirilebilir dosya yönetimi
-- =============================================

DROP TABLE IF EXISTS content.content_attachments CASCADE;

CREATE TABLE content.content_attachments (
    id SERIAL PRIMARY KEY,
    content_id INTEGER NOT NULL,                  -- Bağlı içerik ID
    file_name VARCHAR(255) NOT NULL,              -- Dosya adı
    file_path VARCHAR(500) NOT NULL,              -- Dosya yolu (CDN)
    file_type VARCHAR(100),                       -- Dosya tipi (MIME)
    file_size INTEGER,                            -- Dosya boyutu (byte)
    alt_text VARCHAR(255),                        -- Alternatif metin (SEO/Erişilebilirlik)
    caption VARCHAR(500),                         -- Görsel altı açıklama
    sort_order INTEGER NOT NULL DEFAULT 0,        -- Sıralama
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,   -- Öne çıkan dosya mı? (Kapak görseli)
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER
);

COMMENT ON TABLE content.content_attachments IS 'File attachments for content items including images, documents, and media files';

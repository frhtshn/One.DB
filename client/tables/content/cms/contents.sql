-- =============================================
-- Contents (İçerik Yönetimi)
-- CMS içeriklerinin ana tablosu
-- Sayfa, makale ve duyuru yönetimi
-- =============================================

DROP TABLE IF EXISTS content.contents CASCADE;

CREATE TABLE content.contents (
    id SERIAL PRIMARY KEY,
    content_type_id INTEGER NOT NULL,             -- İçerik türü ID
    slug VARCHAR(255) NOT NULL,                   -- URL uzantısı (SEO)
    featured_image_url VARCHAR(500),              -- Öne çıkan görsel
    version INTEGER NOT NULL DEFAULT 1,           -- Versiyon numarası
    published_at TIMESTAMP WITHOUT TIME ZONE,     -- Yayınlanma tarihi
    expires_at TIMESTAMP WITHOUT TIME ZONE,       -- Yayından kalkma tarihi
    status VARCHAR(20) NOT NULL DEFAULT 'draft',  -- Durum: draft, published, archived
    is_active BOOLEAN NOT NULL DEFAULT TRUE,      -- Aktif mi?
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);

COMMENT ON TABLE content.contents IS 'CMS content master table for pages, articles, and static content with versioning and scheduling';

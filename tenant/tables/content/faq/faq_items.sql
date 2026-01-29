-- =============================================
-- FAQ Items (SSS Maddeleri)
-- Soru ve cevapların metinleri (Translations tablosunda)
-- Görüntülenme ve faydalılık istatistikleri
-- =============================================

DROP TABLE IF EXISTS content.faq_items CASCADE;

CREATE TABLE content.faq_items (
    id SERIAL PRIMARY KEY,
    category_id INTEGER,                          -- Kategori ID
    sort_order INTEGER NOT NULL DEFAULT 0,        -- Sıralama
    view_count INTEGER NOT NULL DEFAULT 0,        -- Görüntülenme sayısı
    helpful_count INTEGER NOT NULL DEFAULT 0,     -- Faydalı oyu sayısı
    not_helpful_count INTEGER NOT NULL DEFAULT 0, -- Faydasız oyu sayısı
    is_featured BOOLEAN NOT NULL DEFAULT FALSE,   -- Öne çıkan soru mu?
    is_active BOOLEAN NOT NULL DEFAULT TRUE,      -- Aktif mi?
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);

COMMENT ON TABLE content.faq_items IS 'FAQ items with view counts and helpfulness ratings for customer self-service';

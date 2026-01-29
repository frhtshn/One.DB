-- =============================================
-- Content Categories (İçerik Kategorileri)
-- İçerik türlerinin gruplandırılması
-- Yardım sayfaları, yasal metinler vb.
-- =============================================

DROP TABLE IF EXISTS content.content_categories CASCADE;

CREATE TABLE content.content_categories (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL,                    -- Kategori kodu
    icon VARCHAR(100),                            -- Kategori ikonu
    sort_order INTEGER NOT NULL DEFAULT 0,        -- Sıralama
    is_active BOOLEAN NOT NULL DEFAULT TRUE,      -- Aktif mi?
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);

COMMENT ON TABLE content.content_categories IS 'Content category definitions for organizing content types into logical groups';

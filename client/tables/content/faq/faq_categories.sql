-- =============================================
-- FAQ Categories (SSS Kategorileri)
-- Sıkça sorulan soruların gruplandırılması
-- =============================================

DROP TABLE IF EXISTS content.faq_categories CASCADE;

CREATE TABLE content.faq_categories (
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

COMMENT ON TABLE content.faq_categories IS 'FAQ category definitions for organizing frequently asked questions';

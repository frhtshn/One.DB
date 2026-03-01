-- =============================================
-- Content Types (İçerik Türleri)
-- Statik içerik sayfalarının tanımları
-- Gizlilik politikası, hakkımızda vb. türler
-- =============================================

DROP TABLE IF EXISTS content.content_types CASCADE;

CREATE TABLE content.content_types (
    id SERIAL PRIMARY KEY,
    category_id INTEGER,                          -- Kategori ID
    code VARCHAR(50) NOT NULL,                    -- İçerik türü kodu (terms, policy)
    template_key VARCHAR(100),                    -- Özel şablon anahtarı
    icon VARCHAR(100),                            -- İkon
    requires_acceptance BOOLEAN NOT NULL DEFAULT FALSE, -- Onay gerektirir mi?
    show_in_footer BOOLEAN NOT NULL DEFAULT FALSE, -- Footerda gösterilsin mi?
    show_in_menu BOOLEAN NOT NULL DEFAULT FALSE,  -- Menüde gösterilsin mi?
    sort_order INTEGER NOT NULL DEFAULT 0,        -- Sıralama
    is_active BOOLEAN NOT NULL DEFAULT TRUE,      -- Aktif mi?
    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),
    created_by INTEGER,
    updated_at TIMESTAMP WITHOUT TIME ZONE,
    updated_by INTEGER
);

COMMENT ON TABLE content.content_types IS 'Content type definitions such as terms, privacy policy, about us with display settings';

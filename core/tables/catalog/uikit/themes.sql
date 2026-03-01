-- =============================================
-- Themes (Temalar)
-- Kullanılabilir frontend temaları
-- =============================================

DROP TABLE IF EXISTS catalog.themes CASCADE;

CREATE TABLE catalog.themes (
    id serial PRIMARY KEY,

    code varchar(50) NOT NULL UNIQUE,             -- Tema kodu (dark_neon, classic_blue)
    name varchar(100) NOT NULL,                   -- Tema adı
    description text,                             -- Açıklama

    version varchar(20) NOT NULL DEFAULT '1.0.0', -- Sürüm
    thumbnail_url varchar(255),                   -- Önizleme görseli

    -- Varsayılan Ayarlar
    default_config jsonb NOT NULL DEFAULT '{}',   -- Varsayılan renkler, fontlar vb.
    -- {
    --   "colors": {"primary": "#ff0000", "secondary": "#00ff00"},
    --   "fonts": {"header": "Roboto", "body": "Open Sans"}
    -- }

    is_active boolean NOT NULL DEFAULT true,
    is_premium boolean NOT NULL DEFAULT false,    -- Ücretli tema mı?

    created_at timestamp NOT NULL DEFAULT now(),
    updated_at timestamp NOT NULL DEFAULT now()
);

COMMENT ON TABLE catalog.themes IS 'Available frontend themes for clients';

-- =============================================
-- Navigation Templates (Navigasyon Şablonları)
-- Tenant'lar için hazır menü setleri
-- =============================================

DROP TABLE IF EXISTS catalog.navigation_templates CASCADE;

CREATE TABLE catalog.navigation_templates (
    id serial PRIMARY KEY,

    code varchar(50) NOT NULL UNIQUE,             -- Şablon kodu (default_casino, default_sportsbook)
    name varchar(100) NOT NULL,                   -- Şablon adı
    description text,

    is_active boolean NOT NULL DEFAULT true,
    is_default boolean NOT NULL DEFAULT false,    -- Yeni tenant için varsayılan mı?

    created_at timestamp NOT NULL DEFAULT now(),
    updated_at timestamp NOT NULL DEFAULT now()
);

COMMENT ON TABLE catalog.navigation_templates IS 'Pre-defined navigation structures for tenants';

-- =============================================
-- Tenant Themes (Tenant Tema Ayarları)
-- Tenant'ın seçtiği tema ve özelleştirmeleri
-- =============================================

DROP TABLE IF EXISTS presentation.tenant_themes CASCADE;

CREATE TABLE presentation.tenant_themes (
    id bigserial PRIMARY KEY,

    tenant_id bigint NOT NULL,                    -- Hangi tenant
    theme_id int NOT NULL,                        -- Hangi tema (catalog.themes)

    -- Konfigürasyon Override
    config jsonb NOT NULL DEFAULT '{}',           -- Tema ayarları override
    -- {
    --   "colors": {"primary": "#123456"},        -- Varsayılanı ezer
    --   "logo_url": "https://...",
    --   "favicon_url": "https://..."
    -- }

    custom_css text,                              -- Advanced CSS override

    is_active boolean NOT NULL DEFAULT true,      -- Aktif tema mı? (Sadece 1 tane aktif olabilir)

    created_at timestamp NOT NULL DEFAULT now(),
    updated_at timestamp NOT NULL DEFAULT now(),

    UNIQUE(tenant_id, theme_id)
);

COMMENT ON TABLE presentation.tenant_themes IS 'Tenant-specific theme configuration and customizations';

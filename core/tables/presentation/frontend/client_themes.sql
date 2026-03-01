-- =============================================
-- Client Themes (Client Tema Ayarları)
-- Client'ın seçtiği tema ve özelleştirmeleri
-- =============================================

DROP TABLE IF EXISTS presentation.client_themes CASCADE;

CREATE TABLE presentation.client_themes (
    id bigserial PRIMARY KEY,

    client_id bigint NOT NULL,                    -- Hangi client
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
    updated_at timestamp NOT NULL DEFAULT now()


);

COMMENT ON TABLE presentation.client_themes IS 'Client-specific theme configuration and customizations';

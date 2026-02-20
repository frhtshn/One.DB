-- =============================================
-- Tablo: presentation.themes
-- Açıklama: Tenant tema seçimi ve özelleştirmeleri.
--           Core'dan taşındı (tenant_id kaldırıldı).
--           theme_id, core catalog.themes referansıdır.
-- =============================================

DROP TABLE IF EXISTS presentation.themes CASCADE;

CREATE TABLE presentation.themes (
    id BIGSERIAL PRIMARY KEY,

    theme_id INT NOT NULL UNIQUE,                  -- Hangi tema (core: catalog.themes — backend doğrular)

    -- Konfigürasyon Override
    config JSONB NOT NULL DEFAULT '{}',           -- Tema ayarları override
    -- {
    --   "colors": {"primary": "#123456"},        -- Varsayılanı ezer
    --   "logo_url": "https://...",
    --   "favicon_url": "https://..."
    -- }

    custom_css TEXT,                              -- İleri düzey CSS override

    is_active BOOLEAN NOT NULL DEFAULT TRUE,      -- Aktif tema mı? (Sadece 1 tane aktif olabilir)

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE presentation.themes IS 'Tenant-specific theme configuration and customizations. theme_id references core catalog.themes (validated by backend).';

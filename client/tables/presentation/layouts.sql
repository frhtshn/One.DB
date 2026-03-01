-- =============================================
-- Tablo: presentation.layouts
-- Açıklama: Sayfa yerleşimleri ve widget tanımları.
--           Core'dan taşındı (tenant_id kaldırıldı).
--           JSONB structure ile FE render optimizasyonu.
-- =============================================

DROP TABLE IF EXISTS presentation.layouts CASCADE;

CREATE TABLE presentation.layouts (
    id BIGSERIAL PRIMARY KEY,

    -- Kapsam
    page_id BIGINT,                               -- Spesifik sayfa için mi? (NULL = Global/Varsayılan)
    layout_name VARCHAR(50) DEFAULT 'default',    -- Layout adı (home, game_detail, dashboard)

    -- Yerleşim Tanımı (JSON Structure)
    -- FE render için tek seferde tüm structure lazım
    structure JSONB NOT NULL DEFAULT '[]',
    -- [
    --   {
    --     "position": "header_top",
    --     "widgets": [
    --       {"widget_code": "logo", "order": 1, "props": {...}},
    --       {"widget_code": "menu", "order": 2, "props": {...}}
    --     ]
    --   }
    -- ]

    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE presentation.layouts IS 'Defines widget placements for tenant pages or global layouts using JSONB structure.';

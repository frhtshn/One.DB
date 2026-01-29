-- =============================================
-- UI Positions (Yerleşim Bölgeleri)
-- Sayfa üzerindeki slot alanları
-- =============================================

DROP TABLE IF EXISTS catalog.ui_positions CASCADE;

CREATE TABLE catalog.ui_positions (
    id serial PRIMARY KEY,

    code varchar(50) NOT NULL UNIQUE,             -- Pozisyon kodu (header_top, sidebar_left, main_content)
    name varchar(100) NOT NULL,                   -- Görünür ad

    is_global boolean DEFAULT false,              -- Tüm sayfalarda var mı? (Header/Footer gibi)

    created_at timestamp NOT NULL DEFAULT now(),
    updated_at timestamp NOT NULL DEFAULT now()
);

COMMENT ON TABLE catalog.ui_positions IS 'Named slots/zones on pages where widgets can be placed';

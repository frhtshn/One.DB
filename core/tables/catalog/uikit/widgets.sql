-- =============================================
-- Widgets (Bileşenler)
-- Sayfa yerleşiminde kullanılabilecek UI parçaları
-- =============================================

DROP TABLE IF EXISTS catalog.widgets CASCADE;

CREATE TABLE catalog.widgets (
    id serial PRIMARY KEY,

    code varchar(50) NOT NULL UNIQUE,             -- Widget kodu (slider_main, jackpot_ticker)
    name varchar(100) NOT NULL,                   -- Widget adı
    description text,

    category varchar(30) NOT NULL,                -- Kategori
    -- CONTENT: Banner, Text, HTML
    -- GAME: Game List, Last Winners, Jackpot
    -- ACCOUNT: Login Form, Register Form, Wallet
    -- NAVIGATION: Menu, Breadcrumb

    -- Teknik Özellikler
    component_name varchar(100) NOT NULL,         -- FE component adı (GameSlider, BannerHero)
    default_props jsonb DEFAULT '{}',             -- Varsayılan props

    is_active boolean NOT NULL DEFAULT true,

    created_at timestamp NOT NULL DEFAULT now(),
    updated_at timestamp NOT NULL DEFAULT now()
);

COMMENT ON TABLE catalog.widgets IS 'Reusable UI widgets available for placement on client pages';

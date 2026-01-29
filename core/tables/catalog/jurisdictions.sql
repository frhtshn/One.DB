-- =============================================
-- Jurisdictions (Lisans Otoriteleri)
-- iGaming düzenleyici kurumları
-- Ülke/bölge bazlı lisans yönetimi
-- =============================================

DROP TABLE IF EXISTS catalog.jurisdictions CASCADE;

CREATE TABLE catalog.jurisdictions (
    id serial PRIMARY KEY,

    -- Temel bilgiler
    code varchar(20) NOT NULL UNIQUE,             -- Kısa kod: MGA, UKGC, GGL, CUR
    name varchar(100) NOT NULL,                   -- Tam ad: Malta Gaming Authority

    -- Ülke/bölge
    country_code character(2) NOT NULL,           -- ISO ülke kodu: MT, GB, DE, CW
    region varchar(50),                           -- Bölge (varsa): Schleswig-Holstein

    -- Düzenleyici detayları
    authority_type varchar(30) NOT NULL,          -- Otorite tipi
    -- NATIONAL: Ulusal düzenleyici
    -- REGIONAL: Bölgesel düzenleyici
    -- OFFSHORE: Offshore lisans

    website_url varchar(255),                     -- Resmi web sitesi
    license_prefix varchar(20),                   -- Lisans numarası öneki

    -- Durum
    is_active boolean NOT NULL DEFAULT true,

    created_at timestamp NOT NULL DEFAULT now(),
    updated_at timestamp NOT NULL DEFAULT now()
);

COMMENT ON TABLE catalog.jurisdictions IS 'iGaming licensing authorities and regulatory bodies by country/region';

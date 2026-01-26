-- =============================================
-- Tablo: catalog.countries
-- Açıklama: Ülke referans kataloğu
-- ISO 3166-1 standartlarına uygun ülke kodlarını içerir
-- =============================================

DROP TABLE IF EXISTS catalog.countries CASCADE;

CREATE TABLE catalog.countries (
    country_code character(2) PRIMARY KEY,      -- ISO 3166-1 alpha-2 ülke kodu (TR, DE, US)
    country_code_a3 character(3) NOT NULL UNIQUE, -- ISO 3166-1 alpha-3 ülke kodu (TUR, DEU, USA)
    country_name varchar(100) NOT NULL          -- Ülke tam adı (İngilizce)
);

COMMENT ON TABLE catalog.countries IS 'Country reference catalog containing ISO 3166-1 compliant country codes';

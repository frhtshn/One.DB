-- =============================================
-- Tablo: catalog.languages
-- Açıklama: Dil referans kataloğu
-- ISO 639-1 standartlarına uygun dil kodlarını içerir
-- =============================================

DROP TABLE IF EXISTS catalog.languages CASCADE;

CREATE TABLE catalog.languages (
    language_code character(2) PRIMARY KEY,   -- ISO 639-1 dil kodu (tr, en, de)
    language_name varchar(100) NOT NULL,      -- Dil tam adı (Turkish, English)
    is_active boolean NOT NULL DEFAULT true   -- Aktif/pasif durumu
);

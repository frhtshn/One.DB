-- =============================================
-- Tablo: catalog.timezones
-- Açıklama: Saat dilimi referans kataloğu
-- Combobox'larda listelemek için kullanılır
-- =============================================

DROP TABLE IF EXISTS catalog.timezones CASCADE;

CREATE TABLE catalog.timezones (
    name varchar(100) PRIMARY KEY,             -- Timezone ID (Europe/Istanbul, UTC)
    utc_offset varchar(10) NOT NULL,           -- UTC ofset string (+03:00, -05:00)
    display_name varchar(150),                 -- UI için gösterim adı ((UTC+03:00) Istanbul)
    is_active boolean NOT NULL DEFAULT true    -- Aktif/Pasif
);

COMMENT ON TABLE catalog.timezones IS 'Timezone reference catalog for UI selection';

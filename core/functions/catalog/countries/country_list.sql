-- ================================================================
-- COUNTRY_LIST: Ülke listesi (Combobox için)
-- core.companies ve core.tenants tablolarında country_code (char 2) kullanılıyor.
-- Dönüş: code (value), name (label)
-- ================================================================

DROP FUNCTION IF EXISTS catalog.country_list();

CREATE OR REPLACE FUNCTION catalog.country_list()
RETURNS TABLE(code CHAR(2), name VARCHAR(100))
LANGUAGE sql
STABLE
AS $$
    SELECT
        country_code AS code,
        country_name AS name
    FROM catalog.countries
    ORDER BY country_name;
$$;

COMMENT ON FUNCTION catalog.country_list() IS 'Returns list of countries for comboboxes (Value: country_code, Label: country_name).';

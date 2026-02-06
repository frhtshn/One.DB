-- ================================================================
-- COUNTRY_LIST: Tüm ülkeleri listeler
-- Admin paneli kullanımı içindir.
-- ================================================================

DROP FUNCTION IF EXISTS catalog.country_list();

CREATE OR REPLACE FUNCTION catalog.country_list()
RETURNS TABLE(country_code CHAR(2), country_name VARCHAR(100))
LANGUAGE sql
STABLE
AS $$
    SELECT c.country_code,  c.country_name
    FROM catalog.countries c
    ORDER BY c.country_code;
$$;

COMMENT ON FUNCTION catalog.country_list IS 'Lists all countries (for admin usage)';

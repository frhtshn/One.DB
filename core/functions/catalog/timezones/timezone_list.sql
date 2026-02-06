-- ================================================================
-- TIMEZONE_LIST: Tüm saat dilimlerini listeler
-- Admin paneli kullanımı içindir, pasifleri de içerir.
-- ================================================================

DROP FUNCTION IF EXISTS catalog.timezone_list();

CREATE OR REPLACE FUNCTION catalog.timezone_list()
RETURNS TABLE(name VARCHAR(100), utc_offset VARCHAR(10))
LANGUAGE sql
STABLE
AS $$
    SELECT t.name, t.utc_offset
    FROM catalog.timezones t
    ORDER BY t.utc_offset DESC, t.name;
$$;

COMMENT ON FUNCTION catalog.timezone_list IS 'Lists all timezones including inactive ones (for admin usage)';

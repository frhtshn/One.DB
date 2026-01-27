-- ================================================================
-- LANGUAGE_LIST: Tüm dilleri listeler
-- Admin paneli kullanımı içindir, pasifleri de içerir.
-- ================================================================

DROP FUNCTION IF EXISTS catalog.language_list();

CREATE OR REPLACE FUNCTION catalog.language_list()
RETURNS TABLE(language_code CHAR(2), language_name VARCHAR(50), is_active BOOLEAN)
LANGUAGE sql
STABLE
AS $$
    SELECT l.language_code, l.language_name, l.is_active
    FROM catalog.languages l
    ORDER BY l.language_code;
$$;

COMMENT ON FUNCTION catalog.language_list IS 'Lists all languages including inactive ones (for admin usage)';

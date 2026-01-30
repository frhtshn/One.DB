-- ================================================================
-- CURRENCY_LIST: Tüm para birimlerini listeler
-- Admin paneli kullanımı içindir, pasifleri de içerir.
-- ================================================================

DROP FUNCTION IF EXISTS catalog.currency_list();

CREATE OR REPLACE FUNCTION catalog.currency_list()
RETURNS TABLE(currency_code CHAR(3), currency_name VARCHAR(100), symbol VARCHAR(10), numeric_code SMALLINT, is_active BOOLEAN)
LANGUAGE sql
STABLE
AS $$
    SELECT c.currency_code, c.currency_name, c.symbol, c.numeric_code, c.is_active
    FROM catalog.currencies c
    ORDER BY c.currency_code;
$$;

COMMENT ON FUNCTION catalog.currency_list IS 'Lists all currencies including inactive ones (for admin usage)';

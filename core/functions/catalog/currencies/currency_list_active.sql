-- ================================================================
-- CURRENCY_LIST_ACTIVE: Aktif Para Birimi Listesi (Combobox için)
-- core.tenants tablosunda base_currency (char 3) kullanılıyor.
-- Dönüş: code (value), name (label), symbol
-- ================================================================

DROP FUNCTION IF EXISTS catalog.currency_list_active();

CREATE OR REPLACE FUNCTION catalog.currency_list_active()
RETURNS TABLE(code CHAR(3), name VARCHAR(100), symbol VARCHAR(10))
LANGUAGE sql
STABLE
AS $$
    SELECT
        currency_code AS code,
        currency_name AS name,
        symbol
    FROM catalog.currencies
    WHERE is_active = TRUE
    ORDER BY currency_name;
$$;

COMMENT ON FUNCTION catalog.currency_list_active() IS 'Returns list of active currencies for comboboxes (Value: currency_code, Label: currency_name)';

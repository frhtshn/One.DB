-- ================================================================
-- CRYPTOCURRENCY_LIST: Tüm kripto para birimlerini listeler
-- Admin paneli kullanımı içindir, pasifleri de içerir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.cryptocurrency_list();

CREATE OR REPLACE FUNCTION catalog.cryptocurrency_list()
RETURNS TABLE(
    id         INT,
    symbol     VARCHAR(20),
    name       VARCHAR(100),
    name_full  VARCHAR(200),
    max_supply NUMERIC(30,8),
    icon_url   VARCHAR(500),
    is_active  BOOLEAN,
    sort_order INT
)
LANGUAGE sql
STABLE
AS $$
    SELECT c.id, c.symbol, c.name, c.name_full, c.max_supply,
           c.icon_url, c.is_active, c.sort_order
    FROM catalog.cryptocurrencies c
    ORDER BY c.sort_order, c.symbol;
$$;

COMMENT ON FUNCTION catalog.cryptocurrency_list IS 'Lists all cryptocurrencies including inactive ones (for admin usage)';

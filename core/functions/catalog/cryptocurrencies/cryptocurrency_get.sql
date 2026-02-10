-- ================================================================
-- CRYPTOCURRENCY_GET: Tek kripto para birimi detayı getirir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.cryptocurrency_get(VARCHAR);

CREATE OR REPLACE FUNCTION catalog.cryptocurrency_get(p_symbol VARCHAR(20))
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
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM catalog.cryptocurrencies WHERE cryptocurrencies.symbol = UPPER(TRIM(p_symbol))) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.cryptocurrency.not-found';
    END IF;

    RETURN QUERY
    SELECT c.id, c.symbol, c.name, c.name_full, c.max_supply,
           c.icon_url, c.is_active, c.sort_order
    FROM catalog.cryptocurrencies c
    WHERE c.symbol = UPPER(TRIM(p_symbol));
END;
$$;

COMMENT ON FUNCTION catalog.cryptocurrency_get(VARCHAR) IS 'Gets details of a specific cryptocurrency by symbol';

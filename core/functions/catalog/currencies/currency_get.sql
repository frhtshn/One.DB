-- ================================================================
-- CURRENCY_GET: Tek para birimi detayı getirir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.currency_get(CHAR(3));

CREATE OR REPLACE FUNCTION catalog.currency_get(p_code CHAR(3))
RETURNS TABLE(currency_code CHAR(3), currency_name VARCHAR(100), symbol VARCHAR(10), numeric_code SMALLINT, is_active BOOLEAN)
LANGUAGE plpgsql
STABLE
AS $$
BEGIN
    IF NOT EXISTS(SELECT 1 FROM catalog.currencies c WHERE c.currency_code = UPPER(p_code)) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.currency.not-found';
    END IF;

    RETURN QUERY
    SELECT c.currency_code, c.currency_name, c.symbol, c.numeric_code, c.is_active
    FROM catalog.currencies c
    WHERE c.currency_code = UPPER(p_code);
END;
$$;

COMMENT ON FUNCTION catalog.currency_get IS 'Gets details of a specific currency by code';

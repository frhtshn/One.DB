-- ================================================================
-- CURRENCY_RATES_LATEST_LIST: Guncel doviz kurlarini doner
-- CurrencyRateGrain (ReadGrain) tarafindan Redis cache miss'te cagrilir
-- ================================================================

DROP FUNCTION IF EXISTS finance.currency_rates_latest_list(CHAR);

CREATE OR REPLACE FUNCTION finance.currency_rates_latest_list(
    p_provider_base_currency CHAR(3)
)
RETURNS TABLE(
    target_currency CHAR(3),
    rate            NUMERIC(18,8),
    rate_timestamp  TIMESTAMP WITHOUT TIME ZONE
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        crl.target_currency,
        crl.rate,
        crl.rate_timestamp
    FROM finance.currency_rates_latest crl
    WHERE crl.provider_base_currency = p_provider_base_currency
    ORDER BY crl.target_currency;
$$;

COMMENT ON FUNCTION finance.currency_rates_latest_list(CHAR) IS 'Lists latest currency rates for a given base currency - used by CurrencyRateGrain on Redis cache miss';

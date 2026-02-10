-- ================================================================
-- CRYPTO_RATES_LATEST_LIST: Güncel kripto kurlarını döner
-- CryptoRateGrain (ReadGrain) tarafından Redis cache miss'te çağrılır
-- ================================================================

DROP FUNCTION IF EXISTS finance.crypto_rates_latest_list(VARCHAR);

CREATE OR REPLACE FUNCTION finance.crypto_rates_latest_list(
    p_base_currency VARCHAR(10)
)
RETURNS TABLE(
    symbol         VARCHAR(20),
    rate           NUMERIC(18,8),
    change_24h     NUMERIC(18,8),
    change_pct_24h NUMERIC(10,4),
    change_7d      NUMERIC(18,8),
    change_pct_7d  NUMERIC(10,4),
    rate_timestamp TIMESTAMP WITHOUT TIME ZONE
)
LANGUAGE sql
STABLE
AS $$
    SELECT
        crl.symbol,
        crl.rate,
        crl.change_24h,
        crl.change_pct_24h,
        crl.change_7d,
        crl.change_pct_7d,
        crl.rate_timestamp
    FROM finance.crypto_rates_latest crl
    WHERE crl.base_currency = p_base_currency
    ORDER BY crl.symbol;
$$;

COMMENT ON FUNCTION finance.crypto_rates_latest_list(VARCHAR) IS 'Lists latest crypto rates for a given base currency - used by CryptoRateGrain on Redis cache miss';

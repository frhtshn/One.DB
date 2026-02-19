-- ================================================================
-- CRYPTO_RATES_BULK_UPSERT: Toplu kripto kur güncelleme
-- CryptoGrain tarafından gRPC ile alınan kurları yazar
-- crypto_rates tablosuna tarihçe INSERT eder
-- crypto_rates_latest tablosuna UPSERT eder
-- Tek transaction'da ikisini de halleder
-- ================================================================

DROP FUNCTION IF EXISTS finance.crypto_rates_bulk_upsert(VARCHAR, VARCHAR, TEXT, TIMESTAMPTZ, TIMESTAMPTZ);

CREATE OR REPLACE FUNCTION finance.crypto_rates_bulk_upsert(
    p_provider        VARCHAR(30),                              -- Kur sağlayıcı (örn: 'coinlayer')
    p_base_currency   VARCHAR(10),                              -- Baz para birimi (örn: 'USD')
    p_rates           TEXT,                                     -- Kur dizisi: [{"symbol":"BTC","rate":97432.50},...]
    p_rate_timestamp  TIMESTAMPTZ,                              -- Kurun geçerli olduğu zaman (provider)
    p_fetched_at      TIMESTAMPTZ DEFAULT now()                 -- gRPC'den çekilme zamanı
)
RETURNS TABLE (
    inserted_count  INT,
    upserted_count  INT
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_inserted INT := 0;
    v_upserted INT := 0;
    v_rates    JSONB;
BEGIN
    -- Parametre doğrulama
    IF p_provider IS NULL OR p_provider = '' THEN
        RAISE EXCEPTION 'error.crypto-rates.provider-required';
    END IF;

    IF p_base_currency IS NULL OR p_base_currency = '' THEN
        RAISE EXCEPTION 'error.crypto-rates.base-currency-required';
    END IF;

    IF p_rates IS NULL OR p_rates = '' THEN
        RAISE EXCEPTION 'error.crypto-rates.rates-empty';
    END IF;

    -- TEXT -> JSONB cast
    v_rates := p_rates::JSONB;

    IF jsonb_array_length(v_rates) = 0 THEN
        RAISE EXCEPTION 'error.crypto-rates.rates-empty';
    END IF;

    IF p_rate_timestamp IS NULL THEN
        RAISE EXCEPTION 'error.crypto-rates.timestamp-required';
    END IF;

    -- Tarihçe tablosuna INSERT (crypto_rates)
    -- Aynı provider+base+symbol+timestamp zaten varsa atla
    INSERT INTO finance.crypto_rates (
        provider,
        base_currency,
        symbol,
        rate,
        rate_timestamp,
        fetched_at
    )
    SELECT
        p_provider,
        p_base_currency,
        (r->>'symbol')::VARCHAR(20),
        (r->>'rate')::NUMERIC(18,8),
        p_rate_timestamp,
        p_fetched_at
    FROM jsonb_array_elements(v_rates) AS r
    ON CONFLICT (provider, base_currency, symbol, rate_timestamp)
    DO NOTHING;

    GET DIAGNOSTICS v_inserted = ROW_COUNT;

    -- Güncel kur tablosuna UPSERT (crypto_rates_latest)
    INSERT INTO finance.crypto_rates_latest (
        provider,
        base_currency,
        symbol,
        rate,
        change_24h,
        change_pct_24h,
        change_7d,
        change_pct_7d,
        rate_timestamp
    )
    SELECT
        p_provider,
        p_base_currency,
        (r->>'symbol')::VARCHAR(20),
        (r->>'rate')::NUMERIC(18,8),
        (r->>'change_24h')::NUMERIC(18,8),
        (r->>'change_pct_24h')::NUMERIC(10,4),
        (r->>'change_7d')::NUMERIC(18,8),
        (r->>'change_pct_7d')::NUMERIC(10,4),
        p_rate_timestamp
    FROM jsonb_array_elements(v_rates) AS r
    ON CONFLICT (provider, base_currency, symbol)
    DO UPDATE SET
        rate           = EXCLUDED.rate,
        change_24h     = EXCLUDED.change_24h,
        change_pct_24h = EXCLUDED.change_pct_24h,
        change_7d      = EXCLUDED.change_7d,
        change_pct_7d  = EXCLUDED.change_pct_7d,
        rate_timestamp = EXCLUDED.rate_timestamp
    WHERE crypto_rates_latest.rate_timestamp < EXCLUDED.rate_timestamp;

    GET DIAGNOSTICS v_upserted = ROW_COUNT;

    RETURN QUERY SELECT v_inserted, v_upserted;
END;
$$;

COMMENT ON FUNCTION finance.crypto_rates_bulk_upsert(VARCHAR, VARCHAR, TEXT, TIMESTAMPTZ, TIMESTAMPTZ) IS 'Bulk upsert crypto rates from CryptoGrain - inserts history and updates latest rates in a single transaction';

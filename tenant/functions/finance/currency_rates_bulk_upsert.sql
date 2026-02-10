-- ================================================================
-- CURRENCY_RATES_BULK_UPSERT: Toplu döviz kuru güncelleme
-- CurrencyGrain tarafından gRPC ile alınan kurları yazar
-- currency_rates tablosuna tarihçe INSERT eder
-- currency_rates_latest tablosuna UPSERT eder
-- Tek transaction'da ikisini de halleder
-- ================================================================

DROP FUNCTION IF EXISTS finance.currency_rates_bulk_upsert(VARCHAR, CHAR, JSONB, TIMESTAMP, TIMESTAMP);

CREATE OR REPLACE FUNCTION finance.currency_rates_bulk_upsert(
    p_provider               VARCHAR(30),                               -- Kur sağlayıcı (örn: 'currencylayer')
    p_provider_base_currency CHAR(3),                                   -- Sağlayıcı baz para birimi (örn: 'EUR')
    p_rates                  TEXT,                                      -- Kur dizisi: [{"currency":"USD","rate":1.036},...]
    p_rate_timestamp         TIMESTAMPTZ,                               -- Kurun geçerli olduğu zaman (provider)
    p_fetched_at             TIMESTAMPTZ DEFAULT now()                   -- API'den çekilme zamanı
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
        RAISE EXCEPTION 'error.currency-rates.provider-required';
    END IF;

    IF p_provider_base_currency IS NULL OR p_provider_base_currency = '' THEN
        RAISE EXCEPTION 'error.currency-rates.base-currency-required';
    END IF;

    IF p_rates IS NULL OR p_rates = '' THEN
        RAISE EXCEPTION 'error.currency-rates.rates-empty';
    END IF;

    -- TEXT -> JSONB cast
    v_rates := p_rates::JSONB;

    IF jsonb_array_length(v_rates) = 0 THEN
        RAISE EXCEPTION 'error.currency-rates.rates-empty';
    END IF;

    IF p_rate_timestamp IS NULL THEN
        RAISE EXCEPTION 'error.currency-rates.timestamp-required';
    END IF;

    -- Tarihçe tablosuna INSERT (currency_rates)
    -- Aynı provider+base+target+timestamp zaten varsa atla
    INSERT INTO finance.currency_rates (
        provider,
        provider_base_currency,
        target_currency,
        rate,
        rate_timestamp,
        fetched_at
    )
    SELECT
        p_provider,
        p_provider_base_currency,
        (r->>'currency')::CHAR(3),
        (r->>'rate')::NUMERIC(18,8),
        p_rate_timestamp,
        p_fetched_at
    FROM jsonb_array_elements(v_rates) AS r
    ON CONFLICT (provider, provider_base_currency, target_currency, rate_timestamp)
    DO NOTHING;

    GET DIAGNOSTICS v_inserted = ROW_COUNT;

    -- Güncel kur tablosuna UPSERT (currency_rates_latest)
    INSERT INTO finance.currency_rates_latest (
        provider,
        provider_base_currency,
        target_currency,
        rate,
        rate_timestamp
    )
    SELECT
        p_provider,
        p_provider_base_currency,
        (r->>'currency')::CHAR(3),
        (r->>'rate')::NUMERIC(18,8),
        p_rate_timestamp
    FROM jsonb_array_elements(v_rates) AS r
    ON CONFLICT (provider, provider_base_currency, target_currency)
    DO UPDATE SET
        rate           = EXCLUDED.rate,
        rate_timestamp = EXCLUDED.rate_timestamp
    WHERE currency_rates_latest.rate_timestamp < EXCLUDED.rate_timestamp;

    GET DIAGNOSTICS v_upserted = ROW_COUNT;

    RETURN QUERY SELECT v_inserted, v_upserted;
END;
$$;

COMMENT ON FUNCTION finance.currency_rates_bulk_upsert(VARCHAR, CHAR, TEXT, TIMESTAMPTZ, TIMESTAMPTZ) IS 'Bulk upsert currency rates from CurrencyGrain - inserts history and updates latest rates in a single transaction';

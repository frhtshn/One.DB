-- =============================================
-- Currency Rates (Döviz Kurları Geçmişi)
-- Harici API'lerden çekilen kur verileri
-- Geçmiş kurlar saklanır (audit/raporlama için)
-- =============================================

DROP TABLE IF EXISTS finance.currency_rates CASCADE;

CREATE TABLE finance.currency_rates (
    id BIGSERIAL PRIMARY KEY,

    provider VARCHAR(30) NOT NULL,                -- Kur sağlayıcı: currencylayer, fixer, ecb
    provider_base_currency CHAR(3) NOT NULL,      -- Sağlayıcı baz para birimi: USD, EUR

    target_currency CHAR(3) NOT NULL,             -- Hedef para birimi: TRY, GBP

    rate NUMERIC(18,8) NOT NULL,                  -- Döviz kuru

    rate_timestamp TIMESTAMP WITHOUT TIME ZONE NOT NULL, -- Kurun geçerli olduğu zaman (provider)
    fetched_at TIMESTAMP WITHOUT TIME ZONE NOT NULL,     -- API'den çekilme zamanı

    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now(),

    UNIQUE (
        provider,
        provider_base_currency,
        target_currency,
        rate_timestamp
    )
);

COMMENT ON TABLE finance.currency_rates IS 'Historical currency exchange rates from external APIs for audit and reporting purposes';

-- =============================================
-- Currency Rates Latest (Güncel Döviz Kurları)
-- Her para birimi için en son kur
-- Hızlı erişim için ayrı tablo
-- =============================================

DROP TABLE IF EXISTS finance.currency_rates_latest CASCADE;

CREATE TABLE finance.currency_rates_latest (
    provider VARCHAR(30) NOT NULL,                -- Kur sağlayıcı
    provider_base_currency CHAR(3) NOT NULL,      -- Baz para birimi
    target_currency CHAR(3) NOT NULL,             -- Hedef para birimi

    rate NUMERIC(18,8) NOT NULL,                  -- Güncel kur
    rate_timestamp TIMESTAMP WITHOUT TIME ZONE NOT NULL, -- Kur zamanı

    PRIMARY KEY (provider, provider_base_currency, target_currency)
);

COMMENT ON TABLE finance.currency_rates_latest IS 'Latest currency exchange rates per currency pair for real-time conversion lookups';

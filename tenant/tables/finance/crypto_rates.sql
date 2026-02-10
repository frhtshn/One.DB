-- =============================================
-- Tablo: finance.crypto_rates
-- Açıklama: Kripto kur tarihçesi
-- CryptoManager gRPC servisinden çekilen kur verileri
-- Geçmiş kurlar saklanır (audit/raporlama için)
-- currency_rates ile aynı yapıda, kripto için
-- =============================================

DROP TABLE IF EXISTS finance.crypto_rates CASCADE;

CREATE TABLE finance.crypto_rates (
    id BIGSERIAL PRIMARY KEY,

    provider VARCHAR(30) NOT NULL,                -- Kur sağlayıcı: coinlayer
    base_currency VARCHAR(10) NOT NULL,           -- Baz para birimi: USD, EUR
    symbol VARCHAR(20) NOT NULL,                  -- Kripto sembolü: BTC, ETH, SOL

    rate NUMERIC(18,8) NOT NULL,                  -- Kripto kuru (1 coin = X base_currency)

    rate_timestamp TIMESTAMP WITHOUT TIME ZONE NOT NULL, -- Kurun geçerli olduğu zaman (provider)
    fetched_at TIMESTAMP WITHOUT TIME ZONE NOT NULL,     -- gRPC'den çekilme zamanı

    created_at TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT now()
);

COMMENT ON TABLE finance.crypto_rates IS 'Historical cryptocurrency rates from CryptoManager gRPC service for audit and reporting purposes';

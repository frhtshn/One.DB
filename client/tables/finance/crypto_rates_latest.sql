-- =============================================
-- Tablo: finance.crypto_rates_latest
-- Açıklama: Güncel kripto kurları
-- Her kripto için en son kur
-- Hızlı erişim için ayrı tablo
-- Değişim verileri Coinlayer Pro /change endpoint'inden
-- =============================================

DROP TABLE IF EXISTS finance.crypto_rates_latest CASCADE;

CREATE TABLE finance.crypto_rates_latest (
    provider VARCHAR(30) NOT NULL,                -- Kur sağlayıcı
    base_currency VARCHAR(10) NOT NULL,           -- Baz para birimi
    symbol VARCHAR(20) NOT NULL,                  -- Kripto sembolü: BTC, ETH, SOL

    rate NUMERIC(18,8) NOT NULL,                  -- Güncel kur
    change_24h NUMERIC(18,8),                     -- 24 saatlik değişim miktarı (Pro /change)
    change_pct_24h NUMERIC(10,4),                 -- 24 saatlik değişim yüzdesi
    change_7d NUMERIC(18,8),                      -- 7 günlük değişim miktarı
    change_pct_7d NUMERIC(10,4),                  -- 7 günlük değişim yüzdesi

    rate_timestamp TIMESTAMP WITHOUT TIME ZONE NOT NULL, -- Kur zamanı

    PRIMARY KEY (provider, base_currency, symbol)
);

COMMENT ON TABLE finance.crypto_rates_latest IS 'Latest cryptocurrency rates per symbol for real-time conversion lookups. Change data from Coinlayer Pro /change endpoint.';

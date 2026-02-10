-- =============================================
-- Tablo: catalog.cryptocurrencies
-- Açıklama: Kripto para birimi kataloğu
-- Coinlayer /list endpoint'inden senkronize edilen
-- desteklenen kripto para birimlerinin master listesi
-- Backend periyodik olarak /list'ten sync yapar
-- =============================================

DROP TABLE IF EXISTS catalog.cryptocurrencies CASCADE;

CREATE TABLE catalog.cryptocurrencies (
    id              SERIAL PRIMARY KEY,                        -- Benzersiz ID
    symbol          VARCHAR(20) NOT NULL UNIQUE,               -- Kripto sembolü: BTC, ETH, SOL
    name            VARCHAR(100) NOT NULL,                     -- Kısa ad: Bitcoin, Ethereum
    name_full       VARCHAR(200),                              -- Tam ad (coinlayer'dan gelen)
    max_supply      NUMERIC(30,8),                             -- Maksimum arz (NULL = sınırsız)
    icon_url        VARCHAR(500),                              -- Coin ikon URL'i
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,             -- Platformda aktif mi?
    sort_order      INT NOT NULL DEFAULT 0,                    -- Görüntüleme sırası
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),        -- Kayıt oluşturma zamanı
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()         -- Son güncelleme zamanı
);

COMMENT ON TABLE catalog.cryptocurrencies IS 'Cryptocurrency reference catalog synced from Coinlayer /list endpoint. Master list of supported crypto assets with metadata.';

-- =============================================
-- Wallets (Cüzdan Tablosu)
-- Oyuncuların para birimlerine göre cüzdan bilgileri
-- Her oyuncunun birden fazla cüzdanı olabilir
-- Fiat (TRY, EUR, USD) ve kripto (BTC, ETH, SOL)
-- =============================================

DROP TABLE IF EXISTS wallet.wallets CASCADE;

CREATE TABLE wallet.wallets (
    id bigserial PRIMARY KEY,
    player_id bigint NOT NULL,                    -- Oyuncu ID
    wallet_type varchar(20) NOT NULL,             -- Cüzdan tipi: REAL, BONUS, LOCKED, COIN
    currency_type smallint NOT NULL DEFAULT 1,    -- Para birimi tipi: 1=Fiat, 2=Crypto
    currency_code varchar(20) NOT NULL,           -- Para birimi: Fiat(TRY,EUR,USD) veya Crypto(BTC,ETH,SOL)
    status smallint NOT NULL DEFAULT 1,           -- Durum: 1=Aktif, 0=Pasif, 2=Dondurulmuş
    is_default boolean NOT NULL DEFAULT false,    -- Varsayılan cüzdan mı?
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now()
);

COMMENT ON TABLE wallet.wallets IS 'Player wallets supporting fiat (REAL, BONUS, LOCKED) and crypto (COIN) currency types per player';

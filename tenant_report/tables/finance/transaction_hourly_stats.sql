-- =============================================
-- Tablo: finance.transaction_hourly_stats
-- Açıklama: Oyuncu bazlı finansal işlem detaylarının saatlik JSONB özeti.
-- İşlem tipi ve metoduna göre gruplanmış veriler tek satırda tutulur.
-- =============================================

DROP TABLE IF EXISTS finance.transaction_hourly_stats CASCADE;

CREATE TABLE finance.transaction_hourly_stats (
    id bigserial,                              -- Benzersiz kayıt ID
    period_hour timestamp with time zone NOT NULL,         -- İlgili saat

    -- Temel Bilgiler
    player_id bigint NOT NULL,                             -- Oyuncu ID
    wallet_id bigint NOT NULL,                             -- Cüzdan ID
    currency varchar(20) NOT NULL,                          -- Para birimi (Fiat: TRY, Crypto: BTC)

    -- Agregasyon
    total_deposit numeric(18, 8) DEFAULT 0,
    total_withdraw numeric(18, 8) DEFAULT 0,
    total_bonus numeric(18, 8) DEFAULT 0,

    -- İşlem Detayları (JSONB)
    -- Yapı: { "TYPE": { "METHOD": { "amount": 100, "count": 1 } } }
    -- Örnek:
    -- {
    --   "DEPOSIT": {
    --     "PAPARA": {"a": 100, "c": 1},
    --     "CC": {"a": 500, "c": 2}
    --   },
    --   "WITHDRAW": {
    --     "CRYPTO": {"a": 200, "c": 1}
    --   }
    -- }
    transaction_details jsonb DEFAULT '{}'::jsonb,

    -- Meta
    updated_at timestamp without time zone,

    PRIMARY KEY (id, period_hour)                              -- Partition key PK'ya dahil
) PARTITION BY RANGE (period_hour);

-- Index moved to indexes/finance.sql

CREATE TABLE finance.transaction_hourly_stats_default PARTITION OF finance.transaction_hourly_stats DEFAULT;

COMMENT ON TABLE finance.transaction_hourly_stats IS 'Consolidated hourly transaction stats using JSONB to group by type and method. Partitioned monthly by period_hour.';

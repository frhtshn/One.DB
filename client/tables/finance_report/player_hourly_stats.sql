-- =============================================
-- Tablo: finance_report.player_hourly_stats
-- Açıklama: Oyuncu bazlı saatlik finansal özet tablosu
-- Eski sistemdeki [TransactionHourlyTotals] tablosunun optimize edilmiş halidir.
-- JSONB kullanılarak dikey (vertical) bazlı kırılımlar esnek hale getirilmiştir.
-- =============================================

DROP TABLE IF EXISTS finance_report.player_hourly_stats CASCADE;

CREATE TABLE finance_report.player_hourly_stats (
    id bigserial,                              -- Benzersiz kayıt ID
    period_hour timestamp with time zone NOT NULL,         -- İlgili saat (Örn: 2026-01-30 14:00:00+00)

    -- Temel Bilgiler
    player_id bigint NOT NULL,                             -- Oyuncu ID
    wallet_id bigint NOT NULL,                             -- Cüzdan ID
    currency varchar(20) NOT NULL,                          -- Para birimi (Fiat: TRY, Crypto: BTC) - Performans için denormalize

    -- Bakiyeler
    balance_start numeric(18, 8) NOT NULL DEFAULT 0,       -- Dönem başı bakiye
    balance_end numeric(18, 8) NOT NULL DEFAULT 0,         -- Dönem sonu bakiye

    -- Ana Kategoriler (Hızlı erişim ve indeksleme için)
    total_transaction_count int DEFAULT 0,                 -- Toplam işlem adedi
    total_volume_in numeric(18, 8) DEFAULT 0,              -- Toplam Giren (Win + Deposit + Bonus)
    total_volume_out numeric(18, 8) DEFAULT 0,             -- Toplam Çıkan (Bet + Withdraw)

    -- Detaylı Kırılımlar (JSONB)
    -- Örn:
    -- {
    --   "sports": {"bet": 100, "win": 50, "count": 10},
    --   "casino": {"bet": 200, "win": 180, "count": 55},
    --   "poker":  {"rake": 5, "win": 10, "count": 2}
    -- }
    game_stats jsonb DEFAULT '{}'::jsonb,

    -- Ödeme Kırılımları (JSONB)
    -- Örn:
    -- {
    --   "deposit": {"amount": 500, "count": 1},
    --   "withdraw": {"amount": 0, "count": 0},
    --   "bonus": {"assigned": 50, "released": 20, "cancelled": 0},
    --   "adjustment": {"amount": 10, "count": 1}
    -- }
    payment_stats jsonb DEFAULT '{}'::jsonb,

    -- Meta
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone,

    PRIMARY KEY (id, period_hour)                              -- Partition key PK'ya dahil
) PARTITION BY RANGE (period_hour);

CREATE TABLE finance_report.player_hourly_stats_default PARTITION OF finance_report.player_hourly_stats DEFAULT;

COMMENT ON TABLE finance_report.player_hourly_stats IS 'Hourly financial summary per player/wallet using JSONB for flexible vertical reporting. Partitioned monthly by period_hour.';

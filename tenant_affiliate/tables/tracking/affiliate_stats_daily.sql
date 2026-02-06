-- =============================================
-- Tablo: tracking.affiliate_stats_daily
-- Açıklama: Affiliate günlük istatistikleri
-- Player istatistiklerinden aggregate edilir
-- Dashboard ve raporlama için
-- =============================================

DROP TABLE IF EXISTS tracking.affiliate_stats_daily CASCADE;

CREATE TABLE tracking.affiliate_stats_daily (
    id bigserial,                              -- Benzersiz kayıt kimliği
    affiliate_id bigint NOT NULL,                          -- Affiliate ID
    stats_date date NOT NULL,                              -- İstatistik tarihi
    currency char(3) NOT NULL,                             -- Para birimi

    -- Oyuncu Metrikleri
    new_signups int NOT NULL DEFAULT 0,                    -- Yeni kayıt sayısı
    new_ftd_count int NOT NULL DEFAULT 0,                  -- Yeni FTD sayısı (First Time Deposit)
    active_players int NOT NULL DEFAULT 0,                 -- Aktif oyuncu sayısı

    -- Depozit Metrikleri
    deposit_count int NOT NULL DEFAULT 0,                  -- Depozit sayısı
    deposit_amount numeric(18,2) NOT NULL DEFAULT 0,       -- Toplam depozit tutarı
    deposit_fee_amount numeric(18,2) NOT NULL DEFAULT 0,   -- PSP komisyonları

    -- Çekim Metrikleri
    withdrawal_count int NOT NULL DEFAULT 0,               -- Çekim sayısı
    withdrawal_amount numeric(18,2) NOT NULL DEFAULT 0,    -- Toplam çekim tutarı
    withdrawal_fee_amount numeric(18,2) NOT NULL DEFAULT 0, -- Çekim işlem maliyetleri

    -- Oyun Metrikleri
    total_bet_amount numeric(18,2) NOT NULL DEFAULT 0,     -- Toplam bahis tutarı
    total_win_amount numeric(18,2) NOT NULL DEFAULT 0,     -- Toplam kazanç tutarı

    -- GGR/NGR
    ggr numeric(18,2) NOT NULL DEFAULT 0,                  -- Gross Gaming Revenue
    bonus_cost numeric(18,2) NOT NULL DEFAULT 0,           -- Bonus maliyeti
    finance_cost numeric(18,2) NOT NULL DEFAULT 0,         -- Finans maliyeti
    total_deductions numeric(18,2) NOT NULL DEFAULT 0,     -- Toplam kesintiler
    ngr numeric(18,2) NOT NULL DEFAULT 0,                  -- Net Gaming Revenue

    -- Oyun/Provider Breakdown
    top_games jsonb,                                       -- En çok oynanan oyunlar
    provider_breakdown jsonb,                              -- Provider bazlı özet

    -- Meta
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now(),

    PRIMARY KEY (id, stats_date),                                -- Partition key PK'ya dahil
    CONSTRAINT uq_affiliate_stats_daily UNIQUE (affiliate_id, stats_date, currency)
) PARTITION BY RANGE (stats_date);

CREATE TABLE tracking.affiliate_stats_daily_default PARTITION OF tracking.affiliate_stats_daily DEFAULT;

COMMENT ON TABLE tracking.affiliate_stats_daily IS 'Daily affiliate statistics. Partitioned monthly by stats_date. Aggregated from player stats for dashboard and reporting.';

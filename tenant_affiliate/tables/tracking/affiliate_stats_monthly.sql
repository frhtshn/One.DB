-- =============================================
-- Tablo: tracking.affiliate_stats_monthly
-- Açıklama: Affiliate aylık istatistikleri
-- Komisyon hesaplaması için ana kaynak
-- Period bazlı toplam değerler
-- =============================================

DROP TABLE IF EXISTS tracking.affiliate_stats_monthly CASCADE;

CREATE TABLE tracking.affiliate_stats_monthly (
    id bigserial,                              -- Benzersiz kayıt kimliği
    affiliate_id bigint NOT NULL,                          -- Affiliate ID
    period_year smallint NOT NULL,                         -- Yıl
    period_month smallint NOT NULL,                        -- Ay (1-12)
    currency char(3) NOT NULL,                             -- Para birimi

    -- Oyuncu Metrikleri
    total_signups int NOT NULL DEFAULT 0,                  -- Toplam kayıt sayısı
    total_ftd_count int NOT NULL DEFAULT 0,                -- Toplam FTD sayısı
    avg_daily_active_players numeric(10,2) NOT NULL DEFAULT 0, -- Ortalama günlük aktif oyuncu
    unique_active_players int NOT NULL DEFAULT 0,          -- Benzersiz aktif oyuncu sayısı

    -- Depozit Metrikleri
    deposit_count int NOT NULL DEFAULT 0,                  -- Depozit sayısı
    deposit_amount numeric(18,2) NOT NULL DEFAULT 0,       -- Toplam depozit tutarı
    deposit_fee_amount numeric(18,2) NOT NULL DEFAULT 0,   -- PSP komisyonları toplamı
    avg_deposit_amount numeric(18,2) NOT NULL DEFAULT 0,   -- Ortalama depozit tutarı

    -- Çekim Metrikleri
    withdrawal_count int NOT NULL DEFAULT 0,               -- Çekim sayısı
    withdrawal_amount numeric(18,2) NOT NULL DEFAULT 0,    -- Toplam çekim tutarı
    withdrawal_fee_amount numeric(18,2) NOT NULL DEFAULT 0, -- Çekim işlem maliyetleri

    -- Oyun Metrikleri
    total_bet_amount numeric(18,2) NOT NULL DEFAULT 0,     -- Toplam bahis tutarı
    total_win_amount numeric(18,2) NOT NULL DEFAULT 0,     -- Toplam kazanç tutarı
    total_bet_count int NOT NULL DEFAULT 0,                -- Toplam bahis sayısı

    -- GGR/NGR (Komisyon Hesaplama Kaynağı)
    ggr numeric(18,2) NOT NULL DEFAULT 0,                  -- Gross Gaming Revenue
    bonus_cost numeric(18,2) NOT NULL DEFAULT 0,           -- Bonus maliyeti
    finance_cost numeric(18,2) NOT NULL DEFAULT 0,         -- Finans maliyeti (PSP fees)
    admin_cost numeric(18,2) NOT NULL DEFAULT 0,           -- Admin/operasyon maliyetleri
    total_deductions numeric(18,2) NOT NULL DEFAULT 0,     -- Toplam kesintiler
    ngr numeric(18,2) NOT NULL DEFAULT 0,                  -- Net Gaming Revenue (ggr - total_deductions)

    -- Network İstatistikleri (Üst affiliate için)
    network_player_count int NOT NULL DEFAULT 0,           -- Alt affiliate'lerden gelen oyuncu sayısı
    network_ggr numeric(18,2) NOT NULL DEFAULT 0,          -- Alt affiliate'lerden gelen GGR
    network_ngr numeric(18,2) NOT NULL DEFAULT 0,          -- Alt affiliate'lerden gelen NGR

    -- Komisyon Özeti
    direct_commission numeric(18,2) NOT NULL DEFAULT 0,    -- Direkt komisyon tutarı
    network_commission numeric(18,2) NOT NULL DEFAULT 0,   -- Network komisyon tutarı
    total_commission numeric(18,2) NOT NULL DEFAULT 0,     -- Toplam komisyon tutarı
    commission_rate_applied numeric(5,2),                  -- Uygulanan tier oranı

    -- Breakdown
    game_breakdown jsonb,                                  -- Oyun bazlı özet
    provider_breakdown jsonb,                              -- Provider bazlı özet
    player_breakdown jsonb,                                -- Top oyuncular özeti

    -- Durum
    is_finalized boolean NOT NULL DEFAULT false,           -- Dönem kapandı mı?
    finalized_at timestamp without time zone,              -- Kapanma zamanı
    commission_batch_id uuid,                              -- Komisyon hesaplama batch ID

    -- Meta
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now(),

    PRIMARY KEY (id, period_year, period_month),                 -- Multi-column partition key PK'ya dahil
    CONSTRAINT uq_affiliate_stats_monthly UNIQUE (affiliate_id, period_year, period_month, currency)
) PARTITION BY RANGE (period_year, period_month);

CREATE TABLE tracking.affiliate_stats_monthly_default PARTITION OF tracking.affiliate_stats_monthly DEFAULT;

COMMENT ON TABLE tracking.affiliate_stats_monthly IS 'Monthly affiliate statistics. Partitioned monthly by (period_year, period_month). Primary source for commission calculation with network stats.';
COMMENT ON COLUMN tracking.affiliate_stats_monthly.network_ngr IS 'NGR from sub-affiliates - used for network commission calculation';

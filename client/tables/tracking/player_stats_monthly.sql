-- =============================================
-- Tablo: tracking.player_stats_monthly
-- Açıklama: Oyuncu aylık özet istatistikleri
-- Günlük tablolardan aggregate edilir
-- Affiliate komisyon hesaplamasında ana kaynak
-- =============================================

DROP TABLE IF EXISTS tracking.player_stats_monthly CASCADE;

CREATE TABLE tracking.player_stats_monthly (
    id bigserial,                              -- Benzersiz kayıt kimliği
    player_id bigint NOT NULL,                             -- Oyuncu ID
    affiliate_id bigint NOT NULL,                          -- Affiliate ID (ay boyunca değişmişse son değer)
    period_year smallint NOT NULL,                         -- Yıl
    period_month smallint NOT NULL,                        -- Ay (1-12)
    currency varchar(20) NOT NULL,                          -- Oyuncunun para birimi (Fiat: TRY, Crypto: BTC)

    -- Depozit Metrikleri
    deposit_count int NOT NULL DEFAULT 0,                  -- Depozit sayısı
    deposit_amount numeric(18,2) NOT NULL DEFAULT 0,       -- Toplam depozit tutarı
    deposit_fee_amount numeric(18,2) NOT NULL DEFAULT 0,   -- PSP komisyonları toplamı
    first_deposit_amount numeric(18,2),                    -- İlk depozit tutarı (FTD)
    first_deposit_at timestamp without time zone,          -- İlk depozit zamanı

    -- Çekim Metrikleri
    withdrawal_count int NOT NULL DEFAULT 0,               -- Çekim sayısı
    withdrawal_amount numeric(18,2) NOT NULL DEFAULT 0,    -- Toplam çekim tutarı
    withdrawal_fee_amount numeric(18,2) NOT NULL DEFAULT 0, -- Çekim işlem maliyetleri

    -- Oyun Metrikleri (tüm oyunlardan toplam)
    total_bet_count int NOT NULL DEFAULT 0,                -- Toplam bahis sayısı
    total_bet_amount numeric(18,2) NOT NULL DEFAULT 0,     -- Toplam bahis tutarı
    total_win_amount numeric(18,2) NOT NULL DEFAULT 0,     -- Toplam kazanç tutarı

    -- GGR/NGR Hesaplaması
    ggr numeric(18,2) NOT NULL DEFAULT 0,                  -- Gross Gaming Revenue
    bonus_cost numeric(18,2) NOT NULL DEFAULT 0,           -- Bonus maliyeti
    finance_cost numeric(18,2) NOT NULL DEFAULT 0,         -- Finans maliyeti (deposit_fee + withdrawal_fee)
    admin_cost numeric(18,2) NOT NULL DEFAULT 0,           -- Diğer admin maliyetleri
    total_deductions numeric(18,2) NOT NULL DEFAULT 0,     -- Toplam kesintiler (bonus + finance + admin)
    ngr numeric(18,2) NOT NULL DEFAULT 0,                  -- Net Gaming Revenue (ggr - total_deductions)

    -- Oyun bazlı detay (JSON summary)
    game_breakdown jsonb,                                  -- Oyun bazlı özet: [{game_id, ggr, ngr}, ...]
    provider_breakdown jsonb,                              -- Provider bazlı özet: [{provider_id, ggr, ngr}, ...]

    -- Aktivite Metrikleri
    active_days int NOT NULL DEFAULT 0,                    -- Aktif gün sayısı
    unique_games_played int NOT NULL DEFAULT 0,            -- Oynanan benzersiz oyun sayısı

    -- Durum
    is_ftd_month boolean NOT NULL DEFAULT false,           -- Bu ay FTD mi? (CPA için)
    is_active boolean NOT NULL DEFAULT true,               -- Aktif oyuncu mu?

    -- Komisyon Hesaplaması
    commission_calculated boolean NOT NULL DEFAULT false,  -- Komisyon hesaplandı mı?
    commission_batch_id uuid,                              -- Hesaplama batch ID

    -- Meta
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now(),

    PRIMARY KEY (id, period_year, period_month),                 -- Multi-column partition key PK'ya dahil
    CONSTRAINT uq_player_monthly UNIQUE (player_id, period_year, period_month)
) PARTITION BY RANGE (period_year, period_month);

CREATE TABLE tracking.player_stats_monthly_default PARTITION OF tracking.player_stats_monthly DEFAULT;

COMMENT ON TABLE tracking.player_stats_monthly IS 'Monthly player statistics. Partitioned monthly by (period_year, period_month). Primary source for affiliate commission calculation.';
COMMENT ON COLUMN tracking.player_stats_monthly.is_ftd_month IS 'First Time Deposit month flag - used for CPA commission model';

-- =============================================
-- Örnek Veri:
--
-- player_id: 1001
-- period: 2026-01
--
-- deposit_count: 5
-- deposit_amount: 10,000.00
--
-- total_bet_amount: 45,000.00
-- total_win_amount: 42,000.00
--
-- ggr: 3,000.00 (45000 - 42000)
-- bonus_cost: 500.00
-- ngr: 2,500.00 (3000 - 500)
--
-- game_breakdown: [
--   {"game_id": 501, "game_name": "Sweet Bonanza", "ggr": 2000, "ngr": 1800},
--   {"game_id": 502, "game_name": "Gates of Olympus", "ggr": 1000, "ngr": 700}
-- ]
-- =============================================

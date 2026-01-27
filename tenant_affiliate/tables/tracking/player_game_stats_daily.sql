-- =============================================
-- Tablo: tracking.player_game_stats_daily
-- Açıklama: Oyuncu günlük oyun istatistikleri
-- Her transaction sonrası worker tarafından güncellenir
-- GGR/NGR hesaplaması için temel tablo
-- Affiliate komisyon hesaplamasında kullanılır
-- =============================================

DROP TABLE IF EXISTS tracking.player_game_stats_daily CASCADE;

CREATE TABLE tracking.player_game_stats_daily (
    id bigserial PRIMARY KEY,                              -- Benzersiz kayıt kimliği
    player_id bigint NOT NULL,                             -- Oyuncu ID
    affiliate_id bigint NOT NULL,                          -- O günkü affiliate ID (snapshot)
    game_date date NOT NULL,                               -- İstatistik tarihi
    game_id bigint NOT NULL,                               -- Oyun ID (game_settings.game_id)
    provider_id bigint NOT NULL,                           -- Provider ID
    currency char(3) NOT NULL,                             -- Oyuncunun para birimi

    -- Oyun Metrikleri
    bet_count int NOT NULL DEFAULT 0,                      -- Bahis sayısı
    bet_amount numeric(18,2) NOT NULL DEFAULT 0,           -- Toplam bahis tutarı
    win_count int NOT NULL DEFAULT 0,                      -- Kazanç sayısı
    win_amount numeric(18,2) NOT NULL DEFAULT 0,           -- Toplam kazanç tutarı

    -- GGR/NGR Hesaplaması
    ggr numeric(18,2) NOT NULL DEFAULT 0,                  -- Gross Gaming Revenue (bet - win)
    bonus_cost numeric(18,2) NOT NULL DEFAULT 0,           -- Bonus maliyeti
    ngr numeric(18,2) NOT NULL DEFAULT 0,                  -- Net Gaming Revenue (ggr - bonus_cost)

    -- Komisyon Hesaplaması (snapshot)
    commission_rate numeric(5,2),                          -- Uygulanan komisyon oranı
    commission_amount numeric(18,2) NOT NULL DEFAULT 0,    -- Hesaplanan komisyon tutarı

    -- Meta
    first_bet_at timestamp without time zone,              -- İlk bahis zamanı
    last_bet_at timestamp without time zone,               -- Son bahis zamanı
    created_at timestamp without time zone NOT NULL DEFAULT now(),
    updated_at timestamp without time zone NOT NULL DEFAULT now(),

    CONSTRAINT uq_player_game_daily UNIQUE (player_id, game_date, game_id)
);

COMMENT ON TABLE tracking.player_game_stats_daily IS 'Daily player game statistics aggregated by worker after each transaction - base for GGR/NGR and commission calculations';
COMMENT ON COLUMN tracking.player_game_stats_daily.ggr IS 'Gross Gaming Revenue = bet_amount - win_amount';
COMMENT ON COLUMN tracking.player_game_stats_daily.ngr IS 'Net Gaming Revenue = ggr - bonus_cost (used for commission calculation)';

-- =============================================
-- Örnek Veri:
--
-- | player_id | game_date  | game_id | bet_amount | win_amount | ggr    | ngr    |
-- |-----------|------------|---------|------------|------------|--------|--------|
-- | 1001      | 2026-01-15 | 501     | 5,000.00   | 4,200.00   | 800.00 | 750.00 |
-- | 1001      | 2026-01-15 | 502     | 3,000.00   | 2,800.00   | 200.00 | 200.00 |
-- | 1001      | 2026-01-16 | 501     | 2,000.00   | 2,500.00   | -500.00| -500.00|
--
-- Affiliate komisyonu NGR üzerinden hesaplanır (negatif NGR = 0 komisyon)
-- =============================================

-- =============================================
-- Tenant Report - Finance Indexes
-- =============================================

-- player_hourly_stats (JSONB Indexes)
-- game_stats içinde spor/casino ayrımını hızlı bulmak için
CREATE INDEX IF NOT EXISTS idx_player_hourly_stats_games ON finance.player_hourly_stats USING gin(game_stats);
-- payment_stats içinde deposit/bonus ayrımını hızlı bulmak için
CREATE INDEX IF NOT EXISTS idx_player_hourly_stats_payments ON finance.player_hourly_stats USING gin(payment_stats);

-- transaction_hourly_stats (JSONB Indexes)
-- transaction_details içinde işlem tiplerini aramak için
CREATE INDEX IF NOT EXISTS idx_transaction_hourly_stats_details ON finance.transaction_hourly_stats USING gin(transaction_details);

-- Standart B-Tree Indexes (Performance)
CREATE INDEX IF NOT EXISTS idx_player_hourly_stats_period ON finance.player_hourly_stats USING btree(period_hour DESC);
CREATE INDEX IF NOT EXISTS idx_player_hourly_stats_player ON finance.player_hourly_stats USING btree(player_id);

CREATE INDEX IF NOT EXISTS idx_transaction_hourly_stats_period ON finance.transaction_hourly_stats USING btree(period_hour DESC);
CREATE INDEX IF NOT EXISTS idx_transaction_hourly_stats_player ON finance.transaction_hourly_stats USING btree(player_id);


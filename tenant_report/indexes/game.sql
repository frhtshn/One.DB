-- =============================================
-- Tenant Report - Game Indexes
-- =============================================

-- game_hourly_stats (JSONB Indexes)
-- game_details içindeki key'lere (game_id) göre arama yapabilmek için
CREATE INDEX idx_game_hourly_stats_games ON game.game_hourly_stats USING gin(game_details);
-- provider_stats içindeki provider_id'lere göre arama yapabilmek için
CREATE INDEX idx_game_hourly_stats_providers ON game.game_hourly_stats USING gin(provider_stats);

-- Standart B-Tree Indexes
CREATE INDEX idx_game_hourly_stats_period ON game.game_hourly_stats USING btree(period_hour DESC);
CREATE INDEX idx_game_hourly_stats_player ON game.game_hourly_stats USING btree(player_id);

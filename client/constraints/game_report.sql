-- =============================================
-- Tenant Report - Game Constraints
-- =============================================

-- game_hourly_stats -> unique (player, wallet, hour)
ALTER TABLE game.game_hourly_stats
    ADD CONSTRAINT uq_game_hourly_stats
    UNIQUE (player_id, wallet_id, period_hour);

-- game_performance_daily -> unique (date, provider, game, currency)
ALTER TABLE game.game_performance_daily
    ADD CONSTRAINT uq_game_performance_daily
    UNIQUE (report_date, provider_id, game_id, currency);

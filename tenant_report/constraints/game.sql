-- =============================================
-- Tenant Report - Game Constraints
-- =============================================

-- game_hourly_stats -> unique (player, wallet, hour)
ALTER TABLE game.game_hourly_stats
    ADD CONSTRAINT uq_game_hourly_stats
    UNIQUE (player_id, wallet_id, period_hour);

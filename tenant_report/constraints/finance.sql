-- =============================================
-- Tenant Report - Finance Constraints
-- =============================================

-- player_hourly_stats -> unique (player, wallet, hour)
ALTER TABLE finance.player_hourly_stats
    ADD CONSTRAINT uq_player_hourly_stats
    UNIQUE (player_id, wallet_id, period_hour);

-- transaction_hourly_stats -> unique (player, wallet, hour)
ALTER TABLE finance.transaction_hourly_stats
    ADD CONSTRAINT uq_transaction_hourly_stats
    UNIQUE (player_id, wallet_id, period_hour);

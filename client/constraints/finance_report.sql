-- =============================================
-- Client Report - Finance Constraints
-- =============================================

-- player_hourly_stats -> unique (player, wallet, hour)
ALTER TABLE finance_report.player_hourly_stats
    ADD CONSTRAINT uq_player_hourly_stats
    UNIQUE (player_id, wallet_id, period_hour);

-- transaction_hourly_stats -> unique (player, wallet, hour)
ALTER TABLE finance_report.transaction_hourly_stats
    ADD CONSTRAINT uq_transaction_hourly_stats
    UNIQUE (player_id, wallet_id, period_hour);

-- system_hourly_kpi -> unique (currency, hour)
ALTER TABLE finance_report.system_hourly_kpi
    ADD CONSTRAINT uq_system_hourly_kpi
    UNIQUE (currency, period_hour);

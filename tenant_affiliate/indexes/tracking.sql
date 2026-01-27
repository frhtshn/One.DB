-- =============================================
-- Tenant Affiliate - Tracking Schema Indexes
-- =============================================

-- player_affiliate_current
CREATE INDEX idx_player_affiliate_current_affiliate ON tracking.player_affiliate_current USING btree(affiliate_id);
CREATE INDEX idx_player_affiliate_current_campaign ON tracking.player_affiliate_current USING btree(campaign_id) WHERE campaign_id IS NOT NULL;
CREATE INDEX idx_player_affiliate_current_assigned ON tracking.player_affiliate_current USING btree(assigned_at DESC);

-- player_affiliate_history
CREATE INDEX idx_player_affiliate_history_player ON tracking.player_affiliate_history USING btree(player_id);
CREATE INDEX idx_player_affiliate_history_affiliate ON tracking.player_affiliate_history USING btree(affiliate_id) WHERE affiliate_id IS NOT NULL;
CREATE INDEX idx_player_affiliate_history_campaign ON tracking.player_affiliate_history USING btree(campaign_id) WHERE campaign_id IS NOT NULL;
CREATE INDEX idx_player_affiliate_history_action ON tracking.player_affiliate_history USING btree(action);
CREATE INDEX idx_player_affiliate_history_validity ON tracking.player_affiliate_history USING btree(valid_from, valid_to);
CREATE INDEX idx_player_affiliate_history_active ON tracking.player_affiliate_history USING btree(player_id, valid_from DESC) WHERE valid_to IS NULL;
CREATE INDEX idx_player_affiliate_history_performer ON tracking.player_affiliate_history USING btree(performed_by_type, performed_by_id) WHERE performed_by_id IS NOT NULL;

-- transaction_events (Worker Queue)
CREATE INDEX idx_transaction_events_pending ON tracking.transaction_events USING btree(status, created_at) WHERE status = 0;
CREATE INDEX idx_transaction_events_player ON tracking.transaction_events USING btree(player_id);
CREATE INDEX idx_transaction_events_affiliate ON tracking.transaction_events USING btree(affiliate_id) WHERE affiliate_id IS NOT NULL;
CREATE INDEX idx_transaction_events_game ON tracking.transaction_events USING btree(game_id) WHERE game_id IS NOT NULL;
CREATE INDEX idx_transaction_events_type ON tracking.transaction_events USING btree(transaction_type);
CREATE INDEX idx_transaction_events_transaction ON tracking.transaction_events USING btree(transaction_id);
CREATE INDEX idx_transaction_events_failed ON tracking.transaction_events USING btree(status, retry_count) WHERE status = 3;

-- player_game_stats_daily
CREATE INDEX idx_player_game_stats_daily_player ON tracking.player_game_stats_daily USING btree(player_id);
CREATE INDEX idx_player_game_stats_daily_affiliate ON tracking.player_game_stats_daily USING btree(affiliate_id);
CREATE INDEX idx_player_game_stats_daily_date ON tracking.player_game_stats_daily USING btree(game_date DESC);
CREATE INDEX idx_player_game_stats_daily_game ON tracking.player_game_stats_daily USING btree(game_id);
CREATE INDEX idx_player_game_stats_daily_provider ON tracking.player_game_stats_daily USING btree(provider_id);
CREATE INDEX idx_player_game_stats_daily_affiliate_date ON tracking.player_game_stats_daily USING btree(affiliate_id, game_date DESC);
CREATE INDEX idx_player_game_stats_daily_ngr ON tracking.player_game_stats_daily USING btree(affiliate_id, game_date, ngr) WHERE ngr > 0;

-- player_stats_monthly
CREATE INDEX idx_player_stats_monthly_player ON tracking.player_stats_monthly USING btree(player_id);
CREATE INDEX idx_player_stats_monthly_affiliate ON tracking.player_stats_monthly USING btree(affiliate_id);
CREATE INDEX idx_player_stats_monthly_period ON tracking.player_stats_monthly USING btree(period_year DESC, period_month DESC);
CREATE INDEX idx_player_stats_monthly_ftd ON tracking.player_stats_monthly USING btree(affiliate_id, period_year, period_month) WHERE is_ftd_month = true;
CREATE INDEX idx_player_stats_monthly_not_calc ON tracking.player_stats_monthly USING btree(period_year, period_month) WHERE commission_calculated = false;

-- affiliate_stats_daily
CREATE INDEX idx_affiliate_stats_daily_affiliate ON tracking.affiliate_stats_daily USING btree(affiliate_id);
CREATE INDEX idx_affiliate_stats_daily_date ON tracking.affiliate_stats_daily USING btree(stats_date DESC);
CREATE INDEX idx_affiliate_stats_daily_affiliate_date ON tracking.affiliate_stats_daily USING btree(affiliate_id, stats_date DESC);
CREATE INDEX idx_affiliate_stats_daily_currency ON tracking.affiliate_stats_daily USING btree(currency);

-- affiliate_stats_monthly
CREATE INDEX idx_affiliate_stats_monthly_affiliate ON tracking.affiliate_stats_monthly USING btree(affiliate_id);
CREATE INDEX idx_affiliate_stats_monthly_period ON tracking.affiliate_stats_monthly USING btree(period_year DESC, period_month DESC);
CREATE INDEX idx_affiliate_stats_monthly_affiliate_period ON tracking.affiliate_stats_monthly USING btree(affiliate_id, period_year DESC, period_month DESC);
CREATE INDEX idx_affiliate_stats_monthly_not_final ON tracking.affiliate_stats_monthly USING btree(period_year, period_month) WHERE is_finalized = false;
CREATE INDEX idx_affiliate_stats_monthly_ngr ON tracking.affiliate_stats_monthly USING btree(ngr DESC) WHERE ngr > 0;

-- player_finance_stats_daily
CREATE INDEX idx_player_finance_daily_player ON tracking.player_finance_stats_daily USING btree(player_id);
CREATE INDEX idx_player_finance_daily_affiliate ON tracking.player_finance_stats_daily USING btree(affiliate_id);
CREATE INDEX idx_player_finance_daily_date ON tracking.player_finance_stats_daily USING btree(stats_date DESC);
CREATE INDEX idx_player_finance_daily_affiliate_date ON tracking.player_finance_stats_daily USING btree(affiliate_id, stats_date DESC);
CREATE INDEX idx_player_finance_daily_cost ON tracking.player_finance_stats_daily USING btree(affiliate_id, stats_date, total_finance_cost) WHERE total_finance_cost > 0;

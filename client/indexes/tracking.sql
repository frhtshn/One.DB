-- =============================================
-- Client Affiliate - Tracking Schema Indexes
-- =============================================

-- player_affiliate_current
CREATE INDEX IF NOT EXISTS idx_player_affiliate_current_affiliate ON tracking.player_affiliate_current USING btree(affiliate_id);
CREATE INDEX IF NOT EXISTS idx_player_affiliate_current_campaign ON tracking.player_affiliate_current USING btree(campaign_id) WHERE campaign_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_player_affiliate_current_assigned ON tracking.player_affiliate_current USING btree(assigned_at DESC);

-- player_affiliate_history
CREATE INDEX IF NOT EXISTS idx_player_affiliate_history_player ON tracking.player_affiliate_history USING btree(player_id);
CREATE INDEX IF NOT EXISTS idx_player_affiliate_history_affiliate ON tracking.player_affiliate_history USING btree(affiliate_id) WHERE affiliate_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_player_affiliate_history_campaign ON tracking.player_affiliate_history USING btree(campaign_id) WHERE campaign_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_player_affiliate_history_action ON tracking.player_affiliate_history USING btree(action);
CREATE INDEX IF NOT EXISTS idx_player_affiliate_history_validity ON tracking.player_affiliate_history USING btree(valid_from, valid_to);
CREATE INDEX IF NOT EXISTS idx_player_affiliate_history_active ON tracking.player_affiliate_history USING btree(player_id, valid_from DESC) WHERE valid_to IS NULL;
CREATE INDEX IF NOT EXISTS idx_player_affiliate_history_performer ON tracking.player_affiliate_history USING btree(performed_by_type, performed_by_id) WHERE performed_by_id IS NOT NULL;

-- transaction_events (Worker Queue)
CREATE INDEX IF NOT EXISTS idx_transaction_events_pending ON tracking.transaction_events USING btree(status, created_at) WHERE status = 0;
CREATE INDEX IF NOT EXISTS idx_transaction_events_player ON tracking.transaction_events USING btree(player_id);
CREATE INDEX IF NOT EXISTS idx_transaction_events_affiliate ON tracking.transaction_events USING btree(affiliate_id) WHERE affiliate_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_transaction_events_game ON tracking.transaction_events USING btree(game_id) WHERE game_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_transaction_events_type ON tracking.transaction_events USING btree(transaction_type);
CREATE INDEX IF NOT EXISTS idx_transaction_events_transaction ON tracking.transaction_events USING btree(transaction_id);
CREATE INDEX IF NOT EXISTS idx_transaction_events_failed ON tracking.transaction_events USING btree(status, retry_count) WHERE status = 3;

-- player_game_stats_daily
CREATE INDEX IF NOT EXISTS idx_player_game_stats_daily_player ON tracking.player_game_stats_daily USING btree(player_id);
CREATE INDEX IF NOT EXISTS idx_player_game_stats_daily_affiliate ON tracking.player_game_stats_daily USING btree(affiliate_id);
CREATE INDEX IF NOT EXISTS idx_player_game_stats_daily_date ON tracking.player_game_stats_daily USING btree(game_date DESC);
CREATE INDEX IF NOT EXISTS idx_player_game_stats_daily_game ON tracking.player_game_stats_daily USING btree(game_id);
CREATE INDEX IF NOT EXISTS idx_player_game_stats_daily_provider ON tracking.player_game_stats_daily USING btree(provider_id);
CREATE INDEX IF NOT EXISTS idx_player_game_stats_daily_affiliate_date ON tracking.player_game_stats_daily USING btree(affiliate_id, game_date DESC);
CREATE INDEX IF NOT EXISTS idx_player_game_stats_daily_ngr ON tracking.player_game_stats_daily USING btree(affiliate_id, game_date, ngr) WHERE ngr > 0;

-- player_stats_monthly
CREATE INDEX IF NOT EXISTS idx_player_stats_monthly_player ON tracking.player_stats_monthly USING btree(player_id);
CREATE INDEX IF NOT EXISTS idx_player_stats_monthly_affiliate ON tracking.player_stats_monthly USING btree(affiliate_id);
CREATE INDEX IF NOT EXISTS idx_player_stats_monthly_period ON tracking.player_stats_monthly USING btree(period_year DESC, period_month DESC);
CREATE INDEX IF NOT EXISTS idx_player_stats_monthly_ftd ON tracking.player_stats_monthly USING btree(affiliate_id, period_year, period_month) WHERE is_ftd_month = true;
CREATE INDEX IF NOT EXISTS idx_player_stats_monthly_not_calc ON tracking.player_stats_monthly USING btree(period_year, period_month) WHERE commission_calculated = false;

-- affiliate_stats_daily
CREATE INDEX IF NOT EXISTS idx_affiliate_stats_daily_affiliate ON tracking.affiliate_stats_daily USING btree(affiliate_id);
CREATE INDEX IF NOT EXISTS idx_affiliate_stats_daily_date ON tracking.affiliate_stats_daily USING btree(stats_date DESC);
CREATE INDEX IF NOT EXISTS idx_affiliate_stats_daily_affiliate_date ON tracking.affiliate_stats_daily USING btree(affiliate_id, stats_date DESC);
CREATE INDEX IF NOT EXISTS idx_affiliate_stats_daily_currency ON tracking.affiliate_stats_daily USING btree(currency);

-- affiliate_stats_monthly
CREATE INDEX IF NOT EXISTS idx_affiliate_stats_monthly_affiliate ON tracking.affiliate_stats_monthly USING btree(affiliate_id);
CREATE INDEX IF NOT EXISTS idx_affiliate_stats_monthly_period ON tracking.affiliate_stats_monthly USING btree(period_year DESC, period_month DESC);
CREATE INDEX IF NOT EXISTS idx_affiliate_stats_monthly_affiliate_period ON tracking.affiliate_stats_monthly USING btree(affiliate_id, period_year DESC, period_month DESC);
CREATE INDEX IF NOT EXISTS idx_affiliate_stats_monthly_not_final ON tracking.affiliate_stats_monthly USING btree(period_year, period_month) WHERE is_finalized = false;
CREATE INDEX IF NOT EXISTS idx_affiliate_stats_monthly_ngr ON tracking.affiliate_stats_monthly USING btree(ngr DESC) WHERE ngr > 0;

-- player_finance_stats_daily
CREATE INDEX IF NOT EXISTS idx_player_finance_daily_player ON tracking.player_finance_stats_daily USING btree(player_id);
CREATE INDEX IF NOT EXISTS idx_player_finance_daily_affiliate ON tracking.player_finance_stats_daily USING btree(affiliate_id);
CREATE INDEX IF NOT EXISTS idx_player_finance_daily_date ON tracking.player_finance_stats_daily USING btree(stats_date DESC);
CREATE INDEX IF NOT EXISTS idx_player_finance_daily_affiliate_date ON tracking.player_finance_stats_daily USING btree(affiliate_id, stats_date DESC);
CREATE INDEX IF NOT EXISTS idx_player_finance_daily_cost ON tracking.player_finance_stats_daily USING btree(affiliate_id, stats_date, total_finance_cost) WHERE total_finance_cost > 0;

-- =============================================
-- Tracking Links, Clicks, Registrations, Promo Codes
-- =============================================

-- tracking_links
CREATE INDEX IF NOT EXISTS idx_tracking_links_affiliate ON tracking.tracking_links USING btree(affiliate_id);
CREATE INDEX IF NOT EXISTS idx_tracking_links_campaign ON tracking.tracking_links USING btree(campaign_id) WHERE campaign_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_tracking_links_short_code ON tracking.tracking_links USING btree(short_code) WHERE short_code IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_tracking_links_custom_slug ON tracking.tracking_links USING btree(custom_slug) WHERE custom_slug IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_tracking_links_type ON tracking.tracking_links USING btree(link_type);
CREATE INDEX IF NOT EXISTS idx_tracking_links_status ON tracking.tracking_links USING btree(is_active, affiliate_id);
CREATE INDEX IF NOT EXISTS idx_tracking_links_created ON tracking.tracking_links USING btree(created_at DESC);

-- link_clicks
CREATE INDEX IF NOT EXISTS idx_link_clicks_click_id ON tracking.link_clicks USING btree(click_id);
CREATE INDEX IF NOT EXISTS idx_link_clicks_tracking_link ON tracking.link_clicks USING btree(tracking_link_id);
CREATE INDEX IF NOT EXISTS idx_link_clicks_affiliate ON tracking.link_clicks USING btree(affiliate_id);
CREATE INDEX IF NOT EXISTS idx_link_clicks_clicked_at ON tracking.link_clicks USING btree(clicked_at DESC);
CREATE INDEX IF NOT EXISTS idx_link_clicks_affiliate_date ON tracking.link_clicks USING btree(affiliate_id, clicked_at DESC);
CREATE INDEX IF NOT EXISTS idx_link_clicks_unconverted ON tracking.link_clicks USING btree(clicked_at DESC) WHERE is_converted = false;
CREATE INDEX IF NOT EXISTS idx_link_clicks_country_code ON tracking.link_clicks USING btree(country_code) WHERE country_code IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_link_clicks_device ON tracking.link_clicks USING btree(device_type) WHERE device_type IS NOT NULL;

-- player_registrations
CREATE INDEX IF NOT EXISTS idx_player_registrations_player ON tracking.player_registrations USING btree(player_id);
CREATE INDEX IF NOT EXISTS idx_player_registrations_affiliate ON tracking.player_registrations USING btree(affiliate_id) WHERE affiliate_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_player_registrations_campaign ON tracking.player_registrations USING btree(campaign_id) WHERE campaign_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_player_registrations_link ON tracking.player_registrations USING btree(tracking_link_id) WHERE tracking_link_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_player_registrations_click ON tracking.player_registrations USING btree(click_id) WHERE click_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_player_registrations_registered ON tracking.player_registrations USING btree(registered_at DESC);
CREATE INDEX IF NOT EXISTS idx_player_registrations_affiliate_date ON tracking.player_registrations USING btree(affiliate_id, registered_at DESC);
CREATE INDEX IF NOT EXISTS idx_player_registrations_source ON tracking.player_registrations USING btree(attribution_source);
CREATE INDEX IF NOT EXISTS idx_player_registrations_ftd_pending ON tracking.player_registrations USING btree(affiliate_id) WHERE is_ftd_completed = false AND affiliate_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_player_registrations_qualified ON tracking.player_registrations USING btree(affiliate_id, qualified_at) WHERE is_qualified = true;
CREATE INDEX IF NOT EXISTS idx_player_registrations_promo ON tracking.player_registrations USING btree(promo_code_id) WHERE promo_code_id IS NOT NULL;

-- promo_codes
CREATE INDEX IF NOT EXISTS idx_promo_codes_code ON tracking.promo_codes USING btree(code);
CREATE INDEX IF NOT EXISTS idx_promo_codes_affiliate ON tracking.promo_codes USING btree(affiliate_id);
CREATE INDEX IF NOT EXISTS idx_promo_codes_campaign ON tracking.promo_codes USING btree(campaign_id) WHERE campaign_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_promo_codes_active ON tracking.promo_codes USING btree(is_active, valid_from, valid_to);
CREATE INDEX IF NOT EXISTS idx_promo_codes_created ON tracking.promo_codes USING btree(created_at DESC);

-- =============================================
-- GIN Indexes for JSONB Columns
-- =============================================

-- tracking.affiliate_stats_daily
CREATE INDEX IF NOT EXISTS idx_affiliate_stats_daily_top_games_gin ON tracking.affiliate_stats_daily USING gin(top_games);
CREATE INDEX IF NOT EXISTS idx_affiliate_stats_daily_provider_gin ON tracking.affiliate_stats_daily USING gin(provider_breakdown);

-- tracking.affiliate_stats_monthly
CREATE INDEX IF NOT EXISTS idx_affiliate_stats_monthly_game_gin ON tracking.affiliate_stats_monthly USING gin(game_breakdown);
CREATE INDEX IF NOT EXISTS idx_affiliate_stats_monthly_provider_gin ON tracking.affiliate_stats_monthly USING gin(provider_breakdown);
CREATE INDEX IF NOT EXISTS idx_affiliate_stats_monthly_player_gin ON tracking.affiliate_stats_monthly USING gin(player_breakdown);

-- tracking.link_clicks
CREATE INDEX IF NOT EXISTS idx_link_clicks_query_params_gin ON tracking.link_clicks USING gin(raw_query_params);

-- tracking.player_finance_stats_daily
CREATE INDEX IF NOT EXISTS idx_player_finance_daily_payment_gin ON tracking.player_finance_stats_daily USING gin(payment_method_breakdown);

-- tracking.player_registrations
CREATE INDEX IF NOT EXISTS idx_player_registrations_fraud_gin ON tracking.player_registrations USING gin(fraud_flags);

-- tracking.player_stats_monthly
CREATE INDEX IF NOT EXISTS idx_player_stats_monthly_game_gin ON tracking.player_stats_monthly USING gin(game_breakdown);
CREATE INDEX IF NOT EXISTS idx_player_stats_monthly_provider_gin ON tracking.player_stats_monthly USING gin(provider_breakdown);

-- tracking.promo_codes
CREATE INDEX IF NOT EXISTS idx_promo_codes_allowed_countries_gin ON tracking.promo_codes USING gin(allowed_countries);
CREATE INDEX IF NOT EXISTS idx_promo_codes_excluded_countries_gin ON tracking.promo_codes USING gin(excluded_countries);

-- tracking.tracking_links
CREATE INDEX IF NOT EXISTS idx_tracking_links_default_params_gin ON tracking.tracking_links USING gin(default_params);
CREATE INDEX IF NOT EXISTS idx_tracking_links_sub_id_params_gin ON tracking.tracking_links USING gin(sub_id_params);


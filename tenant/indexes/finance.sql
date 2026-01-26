-- =============================================
-- Tenant Finance Schema Indexes
-- =============================================

-- currency_rates
CREATE INDEX idx_currency_rates_provider ON finance.currency_rates USING btree(provider);
CREATE INDEX idx_currency_rates_target ON finance.currency_rates USING btree(target_currency);
CREATE INDEX idx_currency_rates_timestamp ON finance.currency_rates USING btree(rate_timestamp DESC);
CREATE INDEX idx_currency_rates_lookup ON finance.currency_rates USING btree(provider, provider_base_currency, target_currency, rate_timestamp DESC);

-- payment_method_settings
CREATE INDEX idx_payment_method_settings_method ON finance.payment_method_settings USING btree(payment_method_id);
CREATE INDEX idx_payment_method_settings_active ON finance.payment_method_settings USING btree(is_active) WHERE is_active = true;

-- payment_method_limits
CREATE INDEX idx_payment_method_limits_method ON finance.payment_method_limits USING btree(payment_method_id);
CREATE INDEX idx_payment_method_limits_currency ON finance.payment_method_limits USING btree(currency_code);

-- payment_player_limits
CREATE INDEX idx_payment_player_limits_player ON finance.payment_player_limits USING btree(player_id);
CREATE INDEX idx_payment_player_limits_method ON finance.payment_player_limits USING btree(payment_method_id);

-- =============================================
-- Tenant Finance Schema Indexes
-- =============================================

-- currency_rates
CREATE INDEX idx_currency_rates_provider ON finance.currency_rates USING btree(provider);
CREATE INDEX idx_currency_rates_target ON finance.currency_rates USING btree(target_currency);
CREATE INDEX idx_currency_rates_timestamp ON finance.currency_rates USING btree(rate_timestamp DESC);
CREATE UNIQUE INDEX idx_currency_rates_lookup ON finance.currency_rates USING btree(provider, provider_base_currency, target_currency, rate_timestamp DESC);

-- operation_types
CREATE UNIQUE INDEX idx_operation_types_code ON finance.operation_types USING btree(code);

-- transaction_types
CREATE UNIQUE INDEX idx_transaction_types_code ON finance.transaction_types USING btree(code);

-- payment_method_settings
CREATE INDEX idx_payment_method_settings_method ON finance.payment_method_settings USING btree(payment_method_id);
CREATE INDEX idx_payment_method_settings_visible ON finance.payment_method_settings USING btree(is_visible) WHERE is_visible = true;

-- payment_method_limits
CREATE INDEX idx_payment_method_limits_method ON finance.payment_method_limits USING btree(payment_method_id);

-- payment_player_limits
CREATE INDEX idx_payment_player_limits_player ON finance.payment_player_limits USING btree(player_id);
CREATE INDEX idx_payment_player_limits_method ON finance.payment_player_limits USING btree(payment_method_id);

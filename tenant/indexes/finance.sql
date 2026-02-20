-- =============================================
-- Tenant Finance Schema Indexes
-- =============================================

-- currency_rates
CREATE INDEX IF NOT EXISTS idx_currency_rates_provider ON finance.currency_rates USING btree(provider);
CREATE INDEX IF NOT EXISTS idx_currency_rates_target ON finance.currency_rates USING btree(target_currency);
CREATE INDEX IF NOT EXISTS idx_currency_rates_timestamp ON finance.currency_rates USING btree(rate_timestamp DESC);
CREATE UNIQUE INDEX IF NOT EXISTS idx_currency_rates_lookup ON finance.currency_rates USING btree(provider, provider_base_currency, target_currency, rate_timestamp DESC);

-- currency_rates_latest
CREATE INDEX IF NOT EXISTS idx_currency_rates_latest_target ON finance.currency_rates_latest USING btree(target_currency);

-- crypto_rates
CREATE INDEX IF NOT EXISTS idx_crypto_rates_provider ON finance.crypto_rates USING btree(provider);
CREATE INDEX IF NOT EXISTS idx_crypto_rates_symbol ON finance.crypto_rates USING btree(symbol);
CREATE INDEX IF NOT EXISTS idx_crypto_rates_timestamp ON finance.crypto_rates USING btree(rate_timestamp DESC);
CREATE UNIQUE INDEX IF NOT EXISTS idx_crypto_rates_lookup ON finance.crypto_rates USING btree(provider, base_currency, symbol, rate_timestamp DESC);

-- crypto_rates_latest
CREATE INDEX IF NOT EXISTS idx_crypto_rates_latest_symbol ON finance.crypto_rates_latest USING btree(symbol);

-- payment_method_settings - Temel indexler
CREATE INDEX IF NOT EXISTS idx_payment_method_settings_provider ON finance.payment_method_settings USING btree(provider_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_payment_method_settings_method_unique ON finance.payment_method_settings USING btree(payment_method_id);

-- payment_method_settings - Görünürlük ve durum
CREATE INDEX IF NOT EXISTS idx_payment_method_settings_enabled ON finance.payment_method_settings USING btree(is_enabled) WHERE is_enabled = true;
CREATE INDEX IF NOT EXISTS idx_payment_method_settings_visible ON finance.payment_method_settings USING btree(is_visible) WHERE is_visible = true;
CREATE INDEX IF NOT EXISTS idx_payment_method_settings_featured ON finance.payment_method_settings USING btree(is_featured) WHERE is_featured = true;

-- payment_method_settings - Kategorilendirme
CREATE INDEX IF NOT EXISTS idx_payment_method_settings_payment_type ON finance.payment_method_settings USING btree(payment_type);
CREATE INDEX IF NOT EXISTS idx_payment_method_settings_features ON finance.payment_method_settings USING GIN(features);

-- payment_method_settings - İşlem yönleri
CREATE INDEX IF NOT EXISTS idx_payment_method_settings_deposit ON finance.payment_method_settings USING btree(allow_deposit) WHERE allow_deposit = true;
CREATE INDEX IF NOT EXISTS idx_payment_method_settings_withdrawal ON finance.payment_method_settings USING btree(allow_withdrawal) WHERE allow_withdrawal = true;

-- payment_method_settings - Sıralama
CREATE INDEX IF NOT EXISTS idx_payment_method_settings_display_order ON finance.payment_method_settings USING btree(display_order);
CREATE INDEX IF NOT EXISTS idx_payment_method_settings_popularity ON finance.payment_method_settings USING btree(popularity_score DESC) WHERE is_enabled = true;

-- payment_method_settings - Cursor pagination (OFFSET yerine cursor-based: display_order, id)
CREATE INDEX IF NOT EXISTS idx_payment_method_settings_cursor ON finance.payment_method_settings USING btree(display_order, id);

-- payment_method_limits
CREATE INDEX IF NOT EXISTS idx_payment_method_limits_method ON finance.payment_method_limits USING btree(payment_method_id);
CREATE INDEX IF NOT EXISTS idx_payment_method_limits_currency ON finance.payment_method_limits USING btree(currency_code);
CREATE UNIQUE INDEX IF NOT EXISTS idx_payment_method_limits_lookup ON finance.payment_method_limits USING btree(payment_method_id, currency_code);

-- payment_method_limits - currency_type filtresi (fiat vs crypto)
CREATE INDEX IF NOT EXISTS idx_payment_method_limits_currency_type ON finance.payment_method_limits USING btree(currency_type);

-- payment_method_limits - aktif limitler (soft delete filtresi)
CREATE INDEX IF NOT EXISTS idx_payment_method_limits_active ON finance.payment_method_limits USING btree(is_active) WHERE is_active = true;

-- payment_player_limits
CREATE INDEX IF NOT EXISTS idx_payment_player_limits_player ON finance.payment_player_limits USING btree(player_id);
CREATE INDEX IF NOT EXISTS idx_payment_player_limits_method ON finance.payment_player_limits USING btree(payment_method_id);

-- payment_player_limits - currency_code filtresi (per-currency limit arama)
CREATE INDEX IF NOT EXISTS idx_payment_player_limits_currency ON finance.payment_player_limits USING btree(currency_code);

-- player_financial_limits
CREATE INDEX IF NOT EXISTS idx_player_financial_limits_player ON finance.player_financial_limits USING btree(player_id);
CREATE INDEX IF NOT EXISTS idx_player_financial_limits_currency ON finance.player_financial_limits USING btree(currency_code);

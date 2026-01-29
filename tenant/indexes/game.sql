-- =============================================
-- Tenant Game Schema Indexes
-- =============================================

-- game_settings
CREATE INDEX idx_game_settings_game ON game.game_settings USING btree(game_id);
CREATE INDEX idx_game_settings_provider ON game.game_settings USING btree(provider_id);
CREATE INDEX idx_game_settings_active ON game.game_settings USING btree(is_active) WHERE is_active = true;

-- game_limits
CREATE INDEX idx_game_limits_game ON game.game_limits USING btree(game_id);
CREATE INDEX idx_game_limits_currency ON game.game_limits USING btree(currency_code);
CREATE UNIQUE INDEX idx_game_limits_lookup ON game.game_limits USING btree(game_id, currency_code);

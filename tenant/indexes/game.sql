-- =============================================
-- Tenant Game Schema Indexes
-- =============================================

-- game_settings - Temel indexler
CREATE INDEX IF NOT EXISTS idx_game_settings_game ON game.game_settings USING btree(game_id);
CREATE INDEX IF NOT EXISTS idx_game_settings_provider ON game.game_settings USING btree(provider_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_game_settings_game_unique ON game.game_settings USING btree(game_id);

-- game_settings - Görünürlük ve durum indexleri
CREATE INDEX IF NOT EXISTS idx_game_settings_enabled ON game.game_settings USING btree(is_enabled) WHERE is_enabled = true;
CREATE INDEX IF NOT EXISTS idx_game_settings_visible ON game.game_settings USING btree(is_visible) WHERE is_visible = true;
CREATE INDEX IF NOT EXISTS idx_game_settings_featured ON game.game_settings USING btree(is_featured) WHERE is_featured = true;

-- game_settings - Kategorilendirme (GIN indexler)
CREATE INDEX IF NOT EXISTS idx_game_settings_categories ON game.game_settings USING GIN(categories);
CREATE INDEX IF NOT EXISTS idx_game_settings_tags ON game.game_settings USING GIN(tags);
CREATE INDEX IF NOT EXISTS idx_game_settings_features ON game.game_settings USING GIN(features);
CREATE INDEX IF NOT EXISTS idx_game_settings_custom_categories ON game.game_settings USING GIN(custom_categories);
CREATE INDEX IF NOT EXISTS idx_game_settings_custom_tags ON game.game_settings USING GIN(custom_tags);

-- game_settings - Oyun tipi ve popülerlik
CREATE INDEX IF NOT EXISTS idx_game_settings_game_type ON game.game_settings USING btree(game_type);
CREATE INDEX IF NOT EXISTS idx_game_settings_popularity ON game.game_settings USING btree(popularity_score DESC) WHERE is_enabled = true;
CREATE INDEX IF NOT EXISTS idx_game_settings_has_jackpot ON game.game_settings USING btree(has_jackpot) WHERE has_jackpot = true;

-- game_settings - Sıralama
CREATE INDEX IF NOT EXISTS idx_game_settings_display_order ON game.game_settings USING btree(display_order);

-- game_limits
CREATE INDEX IF NOT EXISTS idx_game_limits_game ON game.game_limits USING btree(game_id);
CREATE INDEX IF NOT EXISTS idx_game_limits_currency ON game.game_limits USING btree(currency_code);
CREATE UNIQUE INDEX IF NOT EXISTS idx_game_limits_lookup ON game.game_limits USING btree(game_id, currency_code);

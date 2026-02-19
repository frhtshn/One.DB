-- =============================================
-- Tenant Game Schema Indexes
-- =============================================

-- game_settings - Temel indexler
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

-- game_settings - Cursor pagination (OFFSET yerine cursor-based: display_order, id)
CREATE INDEX IF NOT EXISTS idx_game_settings_cursor ON game.game_settings USING btree(display_order, id);

-- game_limits
CREATE INDEX IF NOT EXISTS idx_game_limits_game ON game.game_limits USING btree(game_id);
CREATE INDEX IF NOT EXISTS idx_game_limits_currency ON game.game_limits USING btree(currency_code);
CREATE UNIQUE INDEX IF NOT EXISTS idx_game_limits_lookup ON game.game_limits USING btree(game_id, currency_code);

-- game_limits - currency_type filtresi (fiat vs crypto)
CREATE INDEX IF NOT EXISTS idx_game_limits_currency_type ON game.game_limits USING btree(currency_type);

-- game_limits - aktif limitler (soft delete filtresi)
CREATE INDEX IF NOT EXISTS idx_game_limits_active ON game.game_limits USING btree(is_active) WHERE is_active = true;

-- game_sessions - token arama (her callback'te kullanılır)
CREATE UNIQUE INDEX IF NOT EXISTS idx_game_sessions_token ON game.game_sessions USING btree(session_token);

-- game_sessions - aktif oturumlar (player bazlı)
CREATE INDEX IF NOT EXISTS idx_game_sessions_player_active ON game.game_sessions USING btree(player_id, created_at DESC) WHERE status = 'active';

-- game_sessions - süre dolmuş oturum temizliği
CREATE INDEX IF NOT EXISTS idx_game_sessions_expires ON game.game_sessions USING btree(expires_at) WHERE status = 'active';

-- game_sessions - provider bazlı listeleme
CREATE INDEX IF NOT EXISTS idx_game_sessions_provider ON game.game_sessions USING btree(provider_code, status);

-- =============================================
-- Tenant Auth Schema Indexes
-- =============================================

-- players
CREATE UNIQUE INDEX idx_players_username ON auth.players USING btree(username);
CREATE INDEX idx_players_email_hash ON auth.players USING btree(email_hash);
CREATE INDEX idx_players_status ON auth.players USING btree(status);
CREATE INDEX idx_players_registered ON auth.players USING btree(registered_at DESC);
CREATE INDEX idx_players_last_login ON auth.players USING btree(last_login_at DESC) WHERE last_login_at IS NOT NULL;

-- players - güvenlik indexleri
CREATE INDEX IF NOT EXISTS idx_players_lockout ON auth.players USING btree(lockout_enabled, lockout_end_at) WHERE lockout_enabled = true;

-- player_categories
CREATE UNIQUE INDEX idx_player_categories_code ON auth.player_categories USING btree(category_code);
CREATE INDEX IF NOT EXISTS idx_player_categories_level ON auth.player_categories USING btree(level);

-- player_groups
CREATE UNIQUE INDEX idx_player_groups_code ON auth.player_groups USING btree(group_code);
CREATE INDEX IF NOT EXISTS idx_player_groups_level ON auth.player_groups USING btree(level);

-- player_classification
CREATE INDEX idx_player_classification_player ON auth.player_classification USING btree(player_id);
CREATE INDEX idx_player_classification_category ON auth.player_classification USING btree(player_category_id) WHERE player_category_id IS NOT NULL;
CREATE INDEX idx_player_classification_group ON auth.player_classification USING btree(player_group_id) WHERE player_group_id IS NOT NULL;
CREATE UNIQUE INDEX idx_player_classification_unique ON auth.player_classification USING btree(player_id, player_category_id, player_group_id);

-- player_password_history (son şifreleri hızlı çekmek için)
CREATE INDEX idx_player_password_history_lookup ON auth.player_password_history USING btree(player_id, changed_at DESC);


-- =============================================
-- Client Audit - Player Audit Schema Indexes
-- Oyuncu giriş denemeleri ve oturum kayıtları
-- =============================================

-- =============================================================================
-- login_attempts
-- =============================================================================

-- Player lookup (login_attempt_list)
CREATE INDEX IF NOT EXISTS idx_player_login_attempt_player ON player_audit.login_attempts USING btree(player_id) WHERE player_id IS NOT NULL;

-- IP address lookup (güvenlik araştırması)
CREATE INDEX IF NOT EXISTS idx_player_login_attempt_ip ON player_audit.login_attempts USING btree(ip_address);

-- Time-based queries
CREATE INDEX IF NOT EXISTS idx_player_login_attempt_time ON player_audit.login_attempts USING btree(attempted_at DESC);

-- Brute-force tespiti (login_attempt_failed_list)
CREATE INDEX IF NOT EXISTS idx_player_login_attempt_failed ON player_audit.login_attempts USING btree(player_id, attempted_at DESC) WHERE is_successful = FALSE;

-- IP bazlı brute-force tespiti
CREATE INDEX IF NOT EXISTS idx_player_login_attempt_ip_failed ON player_audit.login_attempts USING btree(ip_address, attempted_at DESC) WHERE is_successful = FALSE;

-- GeoIP ülke kodu (güvenlik analizi)
CREATE INDEX IF NOT EXISTS idx_player_login_attempt_country ON player_audit.login_attempts USING btree(country_code) WHERE country_code IS NOT NULL;

-- Proxy/VPN tespiti (fraud investigation)
CREATE INDEX IF NOT EXISTS idx_player_login_attempt_proxy ON player_audit.login_attempts USING btree(is_proxy) WHERE is_proxy = true;

-- =============================================================================
-- login_sessions
-- =============================================================================

-- Player lookup (login_session_list)
CREATE INDEX IF NOT EXISTS idx_player_login_session_player ON player_audit.login_sessions USING btree(player_id);

-- Session token lookup (login_session_update_activity, login_session_end)
CREATE INDEX IF NOT EXISTS idx_player_login_session_token ON player_audit.login_sessions USING btree(session_token);

-- Aktif oturum sorgusu (login_session_list active_only, login_session_end_all)
CREATE INDEX IF NOT EXISTS idx_player_login_session_active ON player_audit.login_sessions USING btree(player_id) WHERE is_active = TRUE;

-- Aktif token lookup (login_session_update_activity, login_session_end)
CREATE INDEX IF NOT EXISTS idx_player_login_session_token_active ON player_audit.login_sessions USING btree(session_token) WHERE is_active = TRUE;

-- IP address lookup (güvenlik araştırması)
CREATE INDEX IF NOT EXISTS idx_player_login_session_ip ON player_audit.login_sessions USING btree(ip_address);

-- GeoIP ülke kodu (güvenlik analizi)
CREATE INDEX IF NOT EXISTS idx_player_login_session_country ON player_audit.login_sessions USING btree(country_code) WHERE country_code IS NOT NULL;

-- Login zamanı (sıralama ve raporlama)
CREATE INDEX IF NOT EXISTS idx_player_login_session_login ON player_audit.login_sessions USING btree(login_at DESC);

-- Proxy/VPN tespiti (fraud investigation)
CREATE INDEX IF NOT EXISTS idx_player_login_session_proxy ON player_audit.login_sessions USING btree(is_proxy) WHERE is_proxy = true;

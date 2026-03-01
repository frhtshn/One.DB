-- =============================================
-- Client Audit - Affiliate Schema Indexes
-- =============================================

-- login_sessions
CREATE INDEX IF NOT EXISTS idx_aff_login_sessions_token ON affiliate_audit.login_sessions USING btree(session_token);
CREATE INDEX IF NOT EXISTS idx_aff_login_sessions_affiliate ON affiliate_audit.login_sessions USING btree(affiliate_id);
CREATE INDEX IF NOT EXISTS idx_aff_login_sessions_user ON affiliate_audit.login_sessions USING btree(user_id);
CREATE INDEX IF NOT EXISTS idx_aff_login_sessions_login ON affiliate_audit.login_sessions USING btree(login_at DESC);
CREATE INDEX IF NOT EXISTS idx_aff_login_sessions_active ON affiliate_audit.login_sessions USING btree(user_id, is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_aff_login_sessions_ip ON affiliate_audit.login_sessions USING btree(ip_address);

-- login_sessions GeoIP
CREATE INDEX IF NOT EXISTS idx_aff_login_sessions_country ON affiliate_audit.login_sessions USING btree(country_code) WHERE country_code IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_aff_login_sessions_proxy ON affiliate_audit.login_sessions USING btree(is_proxy) WHERE is_proxy = true;

-- login_attempts
CREATE INDEX IF NOT EXISTS idx_aff_login_attempts_email ON affiliate_audit.login_attempts USING btree(email);
CREATE INDEX IF NOT EXISTS idx_aff_login_attempts_ip ON affiliate_audit.login_attempts USING btree(ip_address);
CREATE INDEX IF NOT EXISTS idx_aff_login_attempts_time ON affiliate_audit.login_attempts USING btree(attempted_at DESC);
CREATE INDEX IF NOT EXISTS idx_aff_login_attempts_failed ON affiliate_audit.login_attempts USING btree(ip_address, attempted_at) WHERE is_successful = false;
CREATE INDEX IF NOT EXISTS idx_aff_login_attempts_email_failed ON affiliate_audit.login_attempts USING btree(email, attempted_at) WHERE is_successful = false;

-- login_attempts GeoIP
CREATE INDEX IF NOT EXISTS idx_aff_login_attempts_country ON affiliate_audit.login_attempts USING btree(country_code) WHERE country_code IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_aff_login_attempts_proxy ON affiliate_audit.login_attempts USING btree(is_proxy) WHERE is_proxy = true;

-- user_actions
CREATE INDEX IF NOT EXISTS idx_aff_user_actions_affiliate ON affiliate_audit.user_actions USING btree(affiliate_id);
CREATE INDEX IF NOT EXISTS idx_aff_user_actions_user ON affiliate_audit.user_actions USING btree(user_id);
CREATE INDEX IF NOT EXISTS idx_aff_user_actions_session ON affiliate_audit.user_actions USING btree(session_id) WHERE session_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_aff_user_actions_type ON affiliate_audit.user_actions USING btree(action_type);
CREATE INDEX IF NOT EXISTS idx_aff_user_actions_entity ON affiliate_audit.user_actions USING btree(entity_type, entity_id) WHERE entity_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_aff_user_actions_time ON affiliate_audit.user_actions USING btree(performed_at DESC);
CREATE INDEX IF NOT EXISTS idx_aff_user_actions_affiliate_time ON affiliate_audit.user_actions USING btree(affiliate_id, performed_at DESC);

-- =============================================
-- GIN Indexes for JSONB Columns
-- =============================================

-- affiliate_audit.user_actions (action_data)
CREATE INDEX IF NOT EXISTS idx_aff_user_actions_data_gin ON affiliate_audit.user_actions USING gin(action_data);


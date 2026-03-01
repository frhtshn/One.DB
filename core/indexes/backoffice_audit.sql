-- =============================================
-- Core Audit Schema Indexes
-- Performans indexleri - fonksiyonlara göre optimize edildi
-- Partitioned tablo: indexler her partition'a otomatik uygulanır
-- =============================================

-- auth_audit_log (daily partitioned by created_at)

-- User lookup (auth_audit_list_by_user, auth_audit_failed_logins)
CREATE INDEX IF NOT EXISTS idx_auth_audit_user_id ON backoffice_audit.auth_audit_log USING btree(user_id);

-- Event type lookup (auth_audit_list_by_type)
CREATE INDEX IF NOT EXISTS idx_auth_audit_event_type ON backoffice_audit.auth_audit_log USING btree(event_type);

-- Composite: user + event_type + created_at (auth_audit_failed_logins - brute force detection)
CREATE INDEX IF NOT EXISTS idx_auth_audit_failed_logins ON backoffice_audit.auth_audit_log USING btree(user_id, event_type, created_at DESC)
    WHERE event_type = 'LOGIN_FAILED';

-- Event type + date range (auth_audit_list_by_type with date filter)
CREATE INDEX IF NOT EXISTS idx_auth_audit_type_date ON backoffice_audit.auth_audit_log USING btree(event_type, created_at DESC);

-- Company/Client filtering (admin queries)
CREATE INDEX IF NOT EXISTS idx_auth_audit_company ON backoffice_audit.auth_audit_log USING btree(company_id) WHERE company_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_auth_audit_client ON backoffice_audit.auth_audit_log USING btree(client_id) WHERE client_id IS NOT NULL;

-- Success/failure filtering
CREATE INDEX IF NOT EXISTS idx_auth_audit_success ON backoffice_audit.auth_audit_log USING btree(success) WHERE success = false;

-- IP address lookup (security investigation)
CREATE INDEX IF NOT EXISTS idx_auth_audit_ip ON backoffice_audit.auth_audit_log USING btree(ip_address) WHERE ip_address IS NOT NULL;

-- =========================================================================================
-- GIN Indexes for JSONB Columns
-- =========================================================================================

-- backoffice_audit.auth_audit_log (event_data)
CREATE INDEX IF NOT EXISTS idx_auth_audit_event_data_gin ON backoffice_audit.auth_audit_log USING gin(event_data);

-- GeoIP country code lookup (security investigation by country)
CREATE INDEX IF NOT EXISTS idx_auth_audit_country ON backoffice_audit.auth_audit_log USING btree(country_code) WHERE country_code IS NOT NULL;

-- Proxy/VPN detection (fraud investigation)
CREATE INDEX IF NOT EXISTS idx_auth_audit_proxy ON backoffice_audit.auth_audit_log USING btree(is_proxy) WHERE is_proxy = true;

-- =============================================
-- Core Audit Schema Indexes
-- Performans indexleri - fonksiyonlara göre optimize edildi
-- =============================================

-- auth_audit_log

-- User lookup (auth_audit_list_by_user, auth_audit_failed_logins)
CREATE INDEX idx_auth_audit_user_id ON backoffice.auth_audit_log USING btree(user_id);

-- Event type lookup (auth_audit_list_by_type)
CREATE INDEX idx_auth_audit_event_type ON backoffice.auth_audit_log USING btree(event_type);

-- Composite: user + event_type + created_at (auth_audit_failed_logins - brute force detection)
CREATE INDEX idx_auth_audit_failed_logins ON backoffice.auth_audit_log USING btree(user_id, event_type, created_at DESC)
    WHERE event_type = 'LOGIN_FAILED';

-- Event type + date range (auth_audit_list_by_type with date filter)
CREATE INDEX idx_auth_audit_type_date ON backoffice.auth_audit_log USING btree(event_type, created_at DESC);

-- Time-based queries and cleanup
CREATE INDEX idx_auth_audit_created_at ON backoffice.auth_audit_log USING btree(created_at DESC);

-- Company/Tenant filtering (admin queries)
CREATE INDEX idx_auth_audit_company ON backoffice.auth_audit_log USING btree(company_id) WHERE company_id IS NOT NULL;
CREATE INDEX idx_auth_audit_tenant ON backoffice.auth_audit_log USING btree(tenant_id) WHERE tenant_id IS NOT NULL;

-- Success/failure filtering
CREATE INDEX idx_auth_audit_success ON backoffice.auth_audit_log USING btree(success) WHERE success = false;

-- IP address lookup (security investigation)
CREATE INDEX idx_auth_audit_ip ON backoffice.auth_audit_log USING btree(ip_address) WHERE ip_address IS NOT NULL;

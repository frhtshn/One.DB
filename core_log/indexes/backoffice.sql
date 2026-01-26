-- =============================================
-- Core Log - Backoffice Schema Indexes
-- Performans indexleri - fonksiyonlara göre optimize edildi
-- =============================================

-- backoffice.audit_logs

-- Tenant filtering (audit_list)
CREATE INDEX idx_bo_audit_tenant ON backoffice.audit_logs USING btree(tenant_id) WHERE tenant_id IS NOT NULL;

-- User filtering (audit_list)
CREATE INDEX idx_bo_audit_user ON backoffice.audit_logs USING btree(user_id) WHERE user_id IS NOT NULL;

-- Action filtering (audit_list)
CREATE INDEX idx_bo_audit_action ON backoffice.audit_logs USING btree(action);

-- Entity lookup (audit_list, audit_get)
CREATE INDEX idx_bo_audit_entity ON backoffice.audit_logs USING btree(entity_type, entity_id);

-- Time-based queries (audit_list with date range)
CREATE INDEX idx_bo_audit_created ON backoffice.audit_logs USING btree(created_at DESC);

-- Correlation tracking
CREATE INDEX idx_bo_audit_correlation ON backoffice.audit_logs USING btree(correlation_id) WHERE correlation_id IS NOT NULL;

-- Event lookup
CREATE INDEX idx_bo_audit_event ON backoffice.audit_logs USING btree(event_id);

-- Composite: tenant + action + date (common filter pattern)
CREATE INDEX idx_bo_audit_tenant_action_date ON backoffice.audit_logs USING btree(tenant_id, action, created_at DESC);

-- =============================================
-- Core Log - Backoffice Schema Indexes
-- Performans indexleri - fonksiyonlara göre optimize edildi
-- =============================================

-- backoffice.audit_logs

-- Tenant filtering (audit_list)
CREATE INDEX IF NOT EXISTS idx_bo_audit_tenant ON backoffice.audit_logs USING btree(tenant_id) WHERE tenant_id IS NOT NULL;

-- User filtering (audit_list)
CREATE INDEX IF NOT EXISTS idx_bo_audit_user ON backoffice.audit_logs USING btree(user_id) WHERE user_id IS NOT NULL;

-- Action filtering (audit_list)
CREATE INDEX IF NOT EXISTS idx_bo_audit_action ON backoffice.audit_logs USING btree(action);

-- Entity lookup (audit_list, audit_get)
CREATE INDEX IF NOT EXISTS idx_bo_audit_entity ON backoffice.audit_logs USING btree(entity_type, entity_id);

-- Time-based queries (audit_list with date range)
CREATE INDEX IF NOT EXISTS idx_bo_audit_created ON backoffice.audit_logs USING btree(created_at DESC);

-- Correlation tracking
CREATE INDEX IF NOT EXISTS idx_bo_audit_correlation ON backoffice.audit_logs USING btree(correlation_id) WHERE correlation_id IS NOT NULL;

-- Event lookup
CREATE INDEX IF NOT EXISTS idx_bo_audit_event ON backoffice.audit_logs USING btree(event_id);

-- Composite: tenant + action + date (common filter pattern)
CREATE INDEX IF NOT EXISTS idx_bo_audit_tenant_action_date ON backoffice.audit_logs USING btree(tenant_id, action, created_at DESC);

-- =============================================
-- GIN Indexes for JSONB Columns
-- =============================================

-- backoffice.audit_logs (old_value)
CREATE INDEX IF NOT EXISTS idx_bo_audit_old_value_gin ON backoffice.audit_logs USING gin(old_value);

-- backoffice.audit_logs (new_value)
CREATE INDEX IF NOT EXISTS idx_bo_audit_new_value_gin ON backoffice.audit_logs USING gin(new_value);

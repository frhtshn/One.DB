-- =============================================
-- Core Log - Logs Schema Indexes
-- Performans indexleri - fonksiyonlara göre optimize edildi
-- =============================================

-- =============================================
-- logs.error_logs
-- =============================================

-- Client filtering (error_list, error_stats)
CREATE INDEX IF NOT EXISTS idx_error_logs_client ON logs.error_logs USING btree(client_id) WHERE client_id IS NOT NULL;

-- Error code lookup (error_list, error_stats)
CREATE INDEX IF NOT EXISTS idx_error_logs_code ON logs.error_logs USING btree(error_code);

-- Time-based queries (error_list, error_stats)
CREATE INDEX IF NOT EXISTS idx_error_logs_occurred ON logs.error_logs USING btree(occurred_at DESC);

-- HTTP status filtering (error_stats)
CREATE INDEX IF NOT EXISTS idx_error_logs_http_status ON logs.error_logs USING btree(http_status_code);

-- Retryable errors (error_stats)
CREATE INDEX IF NOT EXISTS idx_error_logs_retryable ON logs.error_logs USING btree(is_retryable) WHERE is_retryable = true;

-- Cluster grouping (error_stats)
CREATE INDEX IF NOT EXISTS idx_error_logs_cluster ON logs.error_logs USING btree(cluster_name) WHERE cluster_name IS NOT NULL;

-- Correlation tracking
CREATE INDEX IF NOT EXISTS idx_error_logs_correlation ON logs.error_logs USING btree(correlation_id) WHERE correlation_id IS NOT NULL;

-- Composite: client + occurred_at (common filter)
CREATE INDEX IF NOT EXISTS idx_error_logs_client_date ON logs.error_logs USING btree(client_id, occurred_at DESC);

-- Composite: error_code + occurred_at (top errors query)
CREATE INDEX IF NOT EXISTS idx_error_logs_code_date ON logs.error_logs USING btree(error_code, occurred_at DESC);


-- =============================================
-- logs.dead_letter_messages
-- =============================================

-- Status filtering (dead_letter_list_pending, dead_letter_stats)
CREATE INDEX IF NOT EXISTS idx_dead_letter_status ON logs.dead_letter_messages USING btree(status);

-- Pending messages lookup (dead_letter_list_pending)
CREATE INDEX IF NOT EXISTS idx_dead_letter_pending ON logs.dead_letter_messages USING btree(status, created_at ASC)
    WHERE status IN ('pending', 'retrying');

-- Event type filtering (dead_letter_stats)
CREATE INDEX IF NOT EXISTS idx_dead_letter_event_type ON logs.dead_letter_messages USING btree(event_type);

-- Client filtering
CREATE INDEX IF NOT EXISTS idx_dead_letter_client ON logs.dead_letter_messages USING btree(client_id) WHERE client_id IS NOT NULL;

-- Event ID lookup (dead_letter_get)
CREATE INDEX IF NOT EXISTS idx_dead_letter_event ON logs.dead_letter_messages USING btree(event_id);

-- Retry count tracking
CREATE INDEX IF NOT EXISTS idx_dead_letter_retry ON logs.dead_letter_messages USING btree(retry_count) WHERE status = 'pending';

-- Time-based cleanup
CREATE INDEX IF NOT EXISTS idx_dead_letter_created ON logs.dead_letter_messages USING btree(created_at);

-- Active messages (dead_letter_list, dead_letter_stats_detailed)
CREATE INDEX IF NOT EXISTS idx_dead_letter_active
    ON logs.dead_letter_messages USING btree(status, created_at DESC) WHERE is_archived = FALSE;

-- Next retry scheduling (dead_letter_get_for_auto_retry)
CREATE INDEX IF NOT EXISTS idx_dead_letter_next_retry
    ON logs.dead_letter_messages USING btree(next_retry_at)
    WHERE next_retry_at IS NOT NULL AND status = 'pending' AND is_archived = FALSE;

-- Status + event type composite (dead_letter_list filtering)
CREATE INDEX IF NOT EXISTS idx_dead_letter_status_type
    ON logs.dead_letter_messages USING btree(status, event_type);

-- Correlation ID lookup
CREATE INDEX IF NOT EXISTS idx_dead_letter_correlation
    ON logs.dead_letter_messages USING btree(correlation_id) WHERE correlation_id IS NOT NULL;

-- Failure category filtering
CREATE INDEX IF NOT EXISTS idx_dead_letter_failure_cat
    ON logs.dead_letter_messages USING btree(failure_category) WHERE failure_category IS NOT NULL;

-- =============================================
-- logs.dead_letter_audit
-- =============================================

-- Dead letter ID lookup (audit trail)
CREATE INDEX IF NOT EXISTS idx_dla_dead_letter_id
    ON logs.dead_letter_audit USING btree(dead_letter_id);

-- Time-based audit queries
CREATE INDEX IF NOT EXISTS idx_dla_performed_at
    ON logs.dead_letter_audit USING btree(performed_at DESC);


-- =============================================
-- logs.audit_logs (Core Audit)
-- =============================================

-- User filtering (core_audit_list)
CREATE INDEX IF NOT EXISTS idx_core_audit_user ON logs.audit_logs USING btree(user_id) WHERE user_id IS NOT NULL;

-- Action filtering (core_audit_list)
CREATE INDEX IF NOT EXISTS idx_core_audit_action ON logs.audit_logs USING btree(action);

-- Entity lookup (core_audit_list)
CREATE INDEX IF NOT EXISTS idx_core_audit_entity ON logs.audit_logs USING btree(entity_type, entity_id);

-- Time-based queries (core_audit_list with date range)
CREATE INDEX IF NOT EXISTS idx_core_audit_created ON logs.audit_logs USING btree(created_at DESC);

-- Event lookup
CREATE INDEX IF NOT EXISTS idx_core_audit_event ON logs.audit_logs USING btree(event_id);

-- Correlation tracking
CREATE INDEX IF NOT EXISTS idx_core_audit_correlation ON logs.audit_logs USING btree(correlation_id) WHERE correlation_id IS NOT NULL;

-- =============================================
-- GIN Indexes for JSONB Columns
-- =============================================

-- logs.error_logs (error_metadata)
CREATE INDEX IF NOT EXISTS idx_error_logs_metadata_gin ON logs.error_logs USING gin(error_metadata);

-- logs.dead_letter_messages (payload)
CREATE INDEX IF NOT EXISTS idx_dead_letter_payload_gin ON logs.dead_letter_messages USING gin(payload);

-- logs.audit_logs (old_value)
CREATE INDEX IF NOT EXISTS idx_core_audit_old_value_gin ON logs.audit_logs USING gin(old_value);

-- logs.audit_logs (new_value)
CREATE INDEX IF NOT EXISTS idx_core_audit_new_value_gin ON logs.audit_logs USING gin(new_value);

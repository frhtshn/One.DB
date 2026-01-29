-- =============================================
-- Tenant KYC Schema Indexes
-- =============================================

-- player_kyc_cases
CREATE UNIQUE INDEX IF NOT EXISTS idx_kyc_cases_player ON kyc.player_kyc_cases USING btree(player_id);
CREATE INDEX IF NOT EXISTS idx_kyc_cases_status ON kyc.player_kyc_cases USING btree(current_status);
CREATE INDEX IF NOT EXISTS idx_kyc_cases_level ON kyc.player_kyc_cases USING btree(kyc_level) WHERE kyc_level IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_kyc_cases_risk ON kyc.player_kyc_cases USING btree(risk_level) WHERE risk_level IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_kyc_cases_reviewer ON kyc.player_kyc_cases USING btree(assigned_reviewer_id) WHERE assigned_reviewer_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_kyc_cases_pending ON kyc.player_kyc_cases USING btree(current_status, created_at) WHERE current_status = 'IN_REVIEW';

-- player_kyc_workflows
CREATE INDEX IF NOT EXISTS idx_kyc_workflows_case ON kyc.player_kyc_workflows USING btree(kyc_case_id);
CREATE INDEX IF NOT EXISTS idx_kyc_workflows_status ON kyc.player_kyc_workflows USING btree(current_status);

-- player_documents
CREATE INDEX IF NOT EXISTS idx_player_documents_player ON kyc.player_documents USING btree(player_id);
CREATE INDEX IF NOT EXISTS idx_player_documents_case ON kyc.player_documents USING btree(kyc_case_id) WHERE kyc_case_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_player_documents_type ON kyc.player_documents USING btree(document_type);
CREATE INDEX IF NOT EXISTS idx_player_documents_status ON kyc.player_documents USING btree(status);

-- player_kyc_provider_logs
CREATE INDEX IF NOT EXISTS idx_kyc_provider_logs_case ON kyc.player_kyc_provider_logs USING btree(kyc_case_id);
CREATE INDEX IF NOT EXISTS idx_kyc_provider_logs_provider ON kyc.player_kyc_provider_logs USING btree(provider_code);

-- player_limits
CREATE INDEX IF NOT EXISTS idx_player_limits_player ON kyc.player_limits USING btree(player_id);
CREATE INDEX IF NOT EXISTS idx_player_limits_type ON kyc.player_limits USING btree(limit_type, limit_period);
CREATE INDEX IF NOT EXISTS idx_player_limits_pending ON kyc.player_limits USING btree(pending_activation_at) WHERE status = 'PENDING_INCREASE';
CREATE UNIQUE INDEX IF NOT EXISTS idx_player_limits_unique ON kyc.player_limits(player_id, limit_type, limit_period, COALESCE(currency_code, 'XXX')) WHERE status = 'ACTIVE';

-- player_restrictions
CREATE INDEX IF NOT EXISTS idx_player_restrictions_player ON kyc.player_restrictions USING btree(player_id);
CREATE INDEX IF NOT EXISTS idx_player_restrictions_type ON kyc.player_restrictions USING btree(restriction_type);
CREATE INDEX IF NOT EXISTS idx_player_restrictions_ends ON kyc.player_restrictions USING btree(ends_at) WHERE status = 'ACTIVE' AND ends_at IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_player_restrictions_active ON kyc.player_restrictions(player_id, status, restriction_type) WHERE status = 'ACTIVE';

-- player_limit_history
CREATE INDEX IF NOT EXISTS idx_player_limit_history_player ON kyc.player_limit_history(player_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_player_limit_history_entity ON kyc.player_limit_history(entity_type, entity_id);

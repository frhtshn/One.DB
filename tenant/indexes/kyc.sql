-- =============================================
-- Tenant KYC Schema Indexes
-- =============================================

-- player_kyc_cases
CREATE UNIQUE INDEX idx_kyc_cases_player ON kyc.player_kyc_cases USING btree(player_id);
CREATE INDEX idx_kyc_cases_status ON kyc.player_kyc_cases USING btree(current_status);
CREATE INDEX idx_kyc_cases_level ON kyc.player_kyc_cases USING btree(kyc_level) WHERE kyc_level IS NOT NULL;
CREATE INDEX idx_kyc_cases_risk ON kyc.player_kyc_cases USING btree(risk_level) WHERE risk_level IS NOT NULL;
CREATE INDEX idx_kyc_cases_reviewer ON kyc.player_kyc_cases USING btree(assigned_reviewer_id) WHERE assigned_reviewer_id IS NOT NULL;
CREATE INDEX idx_kyc_cases_pending ON kyc.player_kyc_cases USING btree(current_status, created_at) WHERE current_status = 'IN_REVIEW';

-- player_kyc_workflows
CREATE INDEX idx_kyc_workflows_case ON kyc.player_kyc_workflows USING btree(case_id);
CREATE INDEX idx_kyc_workflows_status ON kyc.player_kyc_workflows USING btree(status);

-- player_documents
CREATE INDEX idx_player_documents_player ON kyc.player_documents USING btree(player_id);
CREATE INDEX idx_player_documents_case ON kyc.player_documents USING btree(kyc_case_id) WHERE kyc_case_id IS NOT NULL;
CREATE INDEX idx_player_documents_type ON kyc.player_documents USING btree(document_type);
CREATE INDEX idx_player_documents_status ON kyc.player_documents USING btree(status);

-- player_kyc_provider_logs
CREATE INDEX idx_kyc_provider_logs_case ON kyc.player_kyc_provider_logs USING btree(case_id);
CREATE INDEX idx_kyc_provider_logs_provider ON kyc.player_kyc_provider_logs USING btree(provider_code);

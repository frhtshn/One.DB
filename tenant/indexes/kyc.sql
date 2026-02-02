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

-- =============================================
-- GIN Indexes for JSONB Columns
-- =============================================

-- player_limit_history (old_value, new_value)
CREATE INDEX IF NOT EXISTS idx_player_limit_history_old_gin ON kyc.player_limit_history USING gin(old_value);
CREATE INDEX IF NOT EXISTS idx_player_limit_history_new_gin ON kyc.player_limit_history USING gin(new_value);

-- player_kyc_provider_logs (request_payload, response_payload)
CREATE INDEX IF NOT EXISTS idx_kyc_provider_logs_req_gin ON kyc.player_kyc_provider_logs USING gin(request_payload);
CREATE INDEX IF NOT EXISTS idx_kyc_provider_logs_res_gin ON kyc.player_kyc_provider_logs USING gin(response_payload);

-- =============================================
-- New KYC Tables Indexes (Jurisdiction, Screening, Risk, AML)
-- =============================================

-- player_jurisdiction
CREATE UNIQUE INDEX IF NOT EXISTS idx_player_jurisdiction_player ON kyc.player_jurisdiction USING btree(player_id);
CREATE INDEX IF NOT EXISTS idx_player_jurisdiction_country ON kyc.player_jurisdiction USING btree(verified_country_code) WHERE verified_country_code IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_player_jurisdiction_jid ON kyc.player_jurisdiction USING btree(jurisdiction_id);
CREATE INDEX IF NOT EXISTS idx_player_jurisdiction_geo ON kyc.player_jurisdiction USING btree(geo_status);
CREATE INDEX IF NOT EXISTS idx_player_jurisdiction_vpn ON kyc.player_jurisdiction(player_id) WHERE vpn_detected = true;

-- player_screening_results
CREATE INDEX IF NOT EXISTS idx_player_screening_player ON kyc.player_screening_results USING btree(player_id);
CREATE INDEX IF NOT EXISTS idx_player_screening_case ON kyc.player_screening_results USING btree(kyc_case_id) WHERE kyc_case_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_player_screening_type ON kyc.player_screening_results USING btree(screening_type);
CREATE INDEX IF NOT EXISTS idx_player_screening_status ON kyc.player_screening_results USING btree(result_status);
CREATE INDEX IF NOT EXISTS idx_player_screening_review ON kyc.player_screening_results USING btree(review_status) WHERE review_status = 'PENDING';
CREATE INDEX IF NOT EXISTS idx_player_screening_due ON kyc.player_screening_results USING btree(next_screening_due) WHERE next_screening_due IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_player_screening_match ON kyc.player_screening_results(player_id, screening_type) WHERE result_status IN ('POTENTIAL_MATCH', 'CONFIRMED_MATCH');

-- player_screening_results JSONB
CREATE INDEX IF NOT EXISTS idx_player_screening_entities_gin ON kyc.player_screening_results USING gin(matched_entities) WHERE matched_entities IS NOT NULL;

-- player_risk_assessments
CREATE INDEX IF NOT EXISTS idx_player_risk_player ON kyc.player_risk_assessments USING btree(player_id);
CREATE INDEX IF NOT EXISTS idx_player_risk_level ON kyc.player_risk_assessments USING btree(risk_level);
CREATE INDEX IF NOT EXISTS idx_player_risk_type ON kyc.player_risk_assessments USING btree(assessment_type);
CREATE INDEX IF NOT EXISTS idx_player_risk_pending ON kyc.player_risk_assessments(requires_approval) WHERE requires_approval = true AND approved_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_player_risk_latest ON kyc.player_risk_assessments(player_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_player_risk_high ON kyc.player_risk_assessments(player_id) WHERE risk_level IN ('HIGH', 'CRITICAL');

-- player_risk_assessments JSONB
CREATE INDEX IF NOT EXISTS idx_player_risk_factors_gin ON kyc.player_risk_assessments USING gin(risk_factors);
CREATE INDEX IF NOT EXISTS idx_player_risk_actions_gin ON kyc.player_risk_assessments USING gin(recommended_actions) WHERE recommended_actions IS NOT NULL;

-- player_aml_flags
CREATE INDEX IF NOT EXISTS idx_player_aml_player ON kyc.player_aml_flags USING btree(player_id);
CREATE INDEX IF NOT EXISTS idx_player_aml_status ON kyc.player_aml_flags USING btree(status);
CREATE INDEX IF NOT EXISTS idx_player_aml_type ON kyc.player_aml_flags USING btree(flag_type);
CREATE INDEX IF NOT EXISTS idx_player_aml_severity ON kyc.player_aml_flags USING btree(severity);
CREATE INDEX IF NOT EXISTS idx_player_aml_open ON kyc.player_aml_flags(status, severity) WHERE status IN ('OPEN', 'INVESTIGATING', 'ESCALATED');
CREATE INDEX IF NOT EXISTS idx_player_aml_assigned ON kyc.player_aml_flags(assigned_to) WHERE status IN ('OPEN', 'INVESTIGATING') AND assigned_to IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_player_aml_sar ON kyc.player_aml_flags(player_id) WHERE sar_required = true AND sar_filed_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_player_aml_detected ON kyc.player_aml_flags(detected_at DESC);

-- player_aml_flags JSONB
CREATE INDEX IF NOT EXISTS idx_player_aml_transactions_gin ON kyc.player_aml_flags USING gin(related_transactions) WHERE related_transactions IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_player_aml_evidence_gin ON kyc.player_aml_flags USING gin(evidence_data) WHERE evidence_data IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_player_aml_actions_gin ON kyc.player_aml_flags USING gin(actions_taken) WHERE actions_taken IS NOT NULL;

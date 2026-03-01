-- =============================================
-- Client Audit KYC Schema Indexes
-- player_screening_results, player_risk_assessments
-- =============================================

-- player_screening_results
CREATE INDEX IF NOT EXISTS idx_screening_player ON kyc_audit.player_screening_results USING btree(player_id);
CREATE INDEX IF NOT EXISTS idx_screening_case ON kyc_audit.player_screening_results USING btree(kyc_case_id) WHERE kyc_case_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_screening_type ON kyc_audit.player_screening_results USING btree(screening_type);
CREATE INDEX IF NOT EXISTS idx_screening_status ON kyc_audit.player_screening_results USING btree(result_status);
CREATE INDEX IF NOT EXISTS idx_screening_review ON kyc_audit.player_screening_results USING btree(review_status) WHERE review_status = 'PENDING';
CREATE INDEX IF NOT EXISTS idx_screening_due ON kyc_audit.player_screening_results USING btree(next_screening_due) WHERE next_screening_due IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_screening_match ON kyc_audit.player_screening_results(player_id, screening_type) WHERE result_status IN ('POTENTIAL_MATCH', 'CONFIRMED_MATCH');
CREATE INDEX IF NOT EXISTS idx_screening_date ON kyc_audit.player_screening_results USING btree(screened_at DESC);

-- player_screening_results JSONB
CREATE INDEX IF NOT EXISTS idx_screening_entities_gin ON kyc_audit.player_screening_results USING gin(matched_entities) WHERE matched_entities IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_screening_response_gin ON kyc_audit.player_screening_results USING gin(raw_response) WHERE raw_response IS NOT NULL;

-- player_risk_assessments
CREATE INDEX IF NOT EXISTS idx_risk_player ON kyc_audit.player_risk_assessments USING btree(player_id);
CREATE INDEX IF NOT EXISTS idx_risk_level ON kyc_audit.player_risk_assessments USING btree(risk_level);
CREATE INDEX IF NOT EXISTS idx_risk_type ON kyc_audit.player_risk_assessments USING btree(assessment_type);
CREATE INDEX IF NOT EXISTS idx_risk_pending ON kyc_audit.player_risk_assessments(requires_approval) WHERE requires_approval = true AND approved_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_risk_latest ON kyc_audit.player_risk_assessments(player_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_risk_high ON kyc_audit.player_risk_assessments(player_id) WHERE risk_level IN ('HIGH', 'CRITICAL');
CREATE INDEX IF NOT EXISTS idx_risk_trigger ON kyc_audit.player_risk_assessments USING btree(trigger_event) WHERE trigger_event IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_risk_date ON kyc_audit.player_risk_assessments USING btree(created_at DESC);

-- player_risk_assessments JSONB
CREATE INDEX IF NOT EXISTS idx_risk_factors_gin ON kyc_audit.player_risk_assessments USING gin(risk_factors);
CREATE INDEX IF NOT EXISTS idx_risk_actions_gin ON kyc_audit.player_risk_assessments USING gin(recommended_actions) WHERE recommended_actions IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_risk_trigger_gin ON kyc_audit.player_risk_assessments USING gin(trigger_details) WHERE trigger_details IS NOT NULL;

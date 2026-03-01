-- =============================================
-- Client Log KYC Schema Indexes
-- player_kyc_provider_logs
-- =============================================

-- player_kyc_provider_logs
CREATE INDEX IF NOT EXISTS idx_kyc_prov_log_player ON kyc_log.player_kyc_provider_logs USING btree(player_id);
CREATE INDEX IF NOT EXISTS idx_kyc_prov_log_case ON kyc_log.player_kyc_provider_logs USING btree(kyc_case_id);
CREATE INDEX IF NOT EXISTS idx_kyc_prov_log_provider ON kyc_log.player_kyc_provider_logs USING btree(provider_code);
CREATE INDEX IF NOT EXISTS idx_kyc_prov_log_status ON kyc_log.player_kyc_provider_logs USING btree(status);
CREATE INDEX IF NOT EXISTS idx_kyc_prov_log_date ON kyc_log.player_kyc_provider_logs USING btree(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_kyc_prov_log_failed ON kyc_log.player_kyc_provider_logs(provider_code, created_at DESC) WHERE status = 'FAILED';

-- player_kyc_provider_logs JSONB
CREATE INDEX IF NOT EXISTS idx_kyc_prov_log_req_gin ON kyc_log.player_kyc_provider_logs USING gin(request_payload);
CREATE INDEX IF NOT EXISTS idx_kyc_prov_log_res_gin ON kyc_log.player_kyc_provider_logs USING gin(response_payload);

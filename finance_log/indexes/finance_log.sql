-- =============================================
-- Finance Log - Indexes
-- =============================================

-- provider_api_requests
CREATE INDEX IF NOT EXISTS idx_fin_api_req_tenant ON finance_log.provider_api_requests USING btree(tenant_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_fin_api_req_provider ON finance_log.provider_api_requests USING btree(provider_code, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_fin_api_req_player ON finance_log.provider_api_requests USING btree(player_id, created_at DESC) WHERE player_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_fin_api_req_action ON finance_log.provider_api_requests USING btree(action_type, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_fin_api_req_request_id ON finance_log.provider_api_requests USING btree(request_id);
CREATE INDEX IF NOT EXISTS idx_fin_api_req_session ON finance_log.provider_api_requests USING btree(session_token) WHERE session_token IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_fin_api_req_errors ON finance_log.provider_api_requests USING btree(provider_code, created_at DESC) WHERE status IN ('failed', 'timeout', 'error');
CREATE INDEX IF NOT EXISTS idx_fin_api_req_slow ON finance_log.provider_api_requests USING btree(response_time_ms DESC) WHERE response_time_ms > 1000;

-- provider_api_callbacks
CREATE INDEX IF NOT EXISTS idx_fin_api_cb_tenant ON finance_log.provider_api_callbacks USING btree(tenant_id, created_at DESC) WHERE tenant_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_fin_api_cb_provider ON finance_log.provider_api_callbacks USING btree(provider_code, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_fin_api_cb_type ON finance_log.provider_api_callbacks USING btree(callback_type, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_fin_api_cb_session ON finance_log.provider_api_callbacks USING btree(session_token) WHERE session_token IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_fin_api_cb_status ON finance_log.provider_api_callbacks USING btree(processing_status, created_at DESC) WHERE processing_status IN ('failed', 'rejected');
CREATE INDEX IF NOT EXISTS idx_fin_api_cb_ext_tx ON finance_log.provider_api_callbacks USING btree(external_transaction_id) WHERE external_transaction_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_fin_api_cb_source ON finance_log.provider_api_callbacks USING btree(source_ip) WHERE source_ip IS NOT NULL;

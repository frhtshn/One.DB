-- =============================================
-- Game Log - Indexes
-- =============================================

-- provider_api_requests
CREATE INDEX IF NOT EXISTS idx_game_api_req_client ON game_log.provider_api_requests USING btree(client_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_game_api_req_provider ON game_log.provider_api_requests USING btree(provider_code, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_game_api_req_player ON game_log.provider_api_requests USING btree(player_id, created_at DESC) WHERE player_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_game_api_req_action ON game_log.provider_api_requests USING btree(action_type, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_game_api_req_request_id ON game_log.provider_api_requests USING btree(request_id);
CREATE INDEX IF NOT EXISTS idx_game_api_req_round ON game_log.provider_api_requests USING btree(external_round_id) WHERE external_round_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_game_api_req_errors ON game_log.provider_api_requests USING btree(provider_code, created_at DESC) WHERE status IN ('failed', 'timeout', 'error');
CREATE INDEX IF NOT EXISTS idx_game_api_req_slow ON game_log.provider_api_requests USING btree(response_time_ms DESC) WHERE response_time_ms > 1000;

-- provider_api_callbacks
CREATE INDEX IF NOT EXISTS idx_game_api_cb_client ON game_log.provider_api_callbacks USING btree(client_id, created_at DESC) WHERE client_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_game_api_cb_provider ON game_log.provider_api_callbacks USING btree(provider_code, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_game_api_cb_type ON game_log.provider_api_callbacks USING btree(callback_type, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_game_api_cb_round ON game_log.provider_api_callbacks USING btree(external_round_id) WHERE external_round_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_game_api_cb_status ON game_log.provider_api_callbacks USING btree(processing_status, created_at DESC) WHERE processing_status IN ('failed', 'rejected');
CREATE INDEX IF NOT EXISTS idx_game_api_cb_ext_tx ON game_log.provider_api_callbacks USING btree(external_transaction_id) WHERE external_transaction_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_game_api_cb_source ON game_log.provider_api_callbacks USING btree(source_ip) WHERE source_ip IS NOT NULL;

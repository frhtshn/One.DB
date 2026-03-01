-- =============================================
-- Client Log - Affiliate Schema Indexes
-- =============================================

-- api_requests
CREATE INDEX IF NOT EXISTS idx_aff_api_requests_affiliate ON affiliate_log.api_requests USING btree(affiliate_id) WHERE affiliate_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_aff_api_requests_user ON affiliate_log.api_requests USING btree(user_id) WHERE user_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_aff_api_requests_request_id ON affiliate_log.api_requests USING btree(request_id);
CREATE INDEX IF NOT EXISTS idx_aff_api_requests_endpoint ON affiliate_log.api_requests USING btree(endpoint);
CREATE INDEX IF NOT EXISTS idx_aff_api_requests_status ON affiliate_log.api_requests USING btree(response_status);
CREATE INDEX IF NOT EXISTS idx_aff_api_requests_time ON affiliate_log.api_requests USING btree(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_aff_api_requests_errors ON affiliate_log.api_requests USING btree(created_at DESC) WHERE response_status >= 400;
CREATE INDEX IF NOT EXISTS idx_aff_api_requests_slow ON affiliate_log.api_requests USING btree(response_time_ms DESC) WHERE response_time_ms > 1000;

-- report_generations
CREATE INDEX IF NOT EXISTS idx_aff_report_gen_affiliate ON affiliate_log.report_generations USING btree(affiliate_id);
CREATE INDEX IF NOT EXISTS idx_aff_report_gen_user ON affiliate_log.report_generations USING btree(user_id);
CREATE INDEX IF NOT EXISTS idx_aff_report_gen_type ON affiliate_log.report_generations USING btree(report_type);
CREATE INDEX IF NOT EXISTS idx_aff_report_gen_time ON affiliate_log.report_generations USING btree(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_aff_report_gen_affiliate_time ON affiliate_log.report_generations USING btree(affiliate_id, created_at DESC);

-- commission_calculations
CREATE INDEX IF NOT EXISTS idx_aff_comm_calc_batch ON affiliate_log.commission_calculations USING btree(batch_id);
CREATE INDEX IF NOT EXISTS idx_aff_comm_calc_period ON affiliate_log.commission_calculations USING btree(period_start, period_end);
CREATE INDEX IF NOT EXISTS idx_aff_comm_calc_status ON affiliate_log.commission_calculations USING btree(status);
CREATE INDEX IF NOT EXISTS idx_aff_comm_calc_time ON affiliate_log.commission_calculations USING btree(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_aff_comm_calc_type ON affiliate_log.commission_calculations USING btree(calculation_type);

-- =============================================
-- GIN Indexes for JSONB Columns
-- =============================================

-- api_requests
CREATE INDEX IF NOT EXISTS idx_aff_api_requests_query_gin ON affiliate_log.api_requests USING gin(query_params);
CREATE INDEX IF NOT EXISTS idx_aff_api_requests_body_gin ON affiliate_log.api_requests USING gin(request_body);

-- report_generations
CREATE INDEX IF NOT EXISTS idx_aff_report_gen_filters_gin ON affiliate_log.report_generations USING gin(filters);

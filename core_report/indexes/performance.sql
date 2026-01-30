-- =============================================
-- Core Report - Performance Indexes
-- =============================================

CREATE INDEX idx_provider_global_daily_date ON performance.provider_global_daily USING btree(report_date DESC);
CREATE INDEX idx_provider_global_daily_provider ON performance.provider_global_daily USING btree(provider_id);

-- =============================================
-- Core Report - Performance Indexes
-- =============================================

-- Provider Stats
CREATE INDEX IF NOT EXISTS idx_provider_global_daily_date ON performance.provider_global_daily USING btree(report_date DESC);
CREATE INDEX IF NOT EXISTS idx_provider_global_daily_provider ON performance.provider_global_daily USING btree(provider_id);

-- Payment Stats
CREATE INDEX IF NOT EXISTS idx_payment_global_daily_date ON performance.payment_global_daily USING btree(report_date DESC);
CREATE INDEX IF NOT EXISTS idx_payment_global_daily_method ON performance.payment_global_daily USING btree(method_id);

-- System Traffic Stats
CREATE INDEX IF NOT EXISTS idx_tenant_traffic_hourly_date ON performance.tenant_traffic_hourly USING btree(period_hour DESC);
CREATE INDEX IF NOT EXISTS idx_tenant_traffic_hourly_company ON performance.tenant_traffic_hourly USING btree(company_id);

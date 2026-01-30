-- =============================================
-- Core Report - Finance Indexes
-- =============================================

CREATE INDEX idx_tenant_daily_kpi_company ON finance.tenant_daily_kpi USING btree(company_id, report_date);
CREATE INDEX idx_tenant_daily_kpi_date ON finance.tenant_daily_kpi USING btree(report_date DESC);

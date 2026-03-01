-- =============================================
-- Core Report - Finance Indexes
-- =============================================

CREATE INDEX IF NOT EXISTS idx_client_daily_kpi_company ON finance_report.client_daily_kpi USING btree(company_id, report_date);
CREATE INDEX IF NOT EXISTS idx_client_daily_kpi_date ON finance_report.client_daily_kpi USING btree(report_date DESC);

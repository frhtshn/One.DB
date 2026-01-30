-- =============================================
-- Core Report - Billing Indexes
-- =============================================

CREATE INDEX idx_monthly_invoices_company ON billing.monthly_invoices USING btree(company_id, period_year, period_month);
CREATE INDEX idx_monthly_invoices_status ON billing.monthly_invoices USING btree(status);

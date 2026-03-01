-- =============================================
-- Core Report - Billing Constraints
-- =============================================

ALTER TABLE billing_report.monthly_invoices
    ADD CONSTRAINT uq_monthly_invoices
    UNIQUE (client_id, period_year, period_month, currency, created_at);

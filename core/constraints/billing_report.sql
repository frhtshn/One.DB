-- =============================================
-- Core Report - Billing Constraints
-- =============================================

ALTER TABLE billing.monthly_invoices
    ADD CONSTRAINT uq_monthly_invoices
    UNIQUE (tenant_id, period_year, period_month, currency, created_at);

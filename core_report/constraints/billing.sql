-- =============================================
-- Core Report - Billing Constraints
-- =============================================

-- monthly_invoices -> unique (tenant, year, month, currency)
ALTER TABLE billing.monthly_invoices
    ADD CONSTRAINT uq_monthly_invoices
    UNIQUE (tenant_id, period_year, period_month, currency);

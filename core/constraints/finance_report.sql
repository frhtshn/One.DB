-- =============================================
-- Core Report - Finance Constraints
-- =============================================

-- tenant_daily_kpi -> unique (tenant, date, currency)
ALTER TABLE finance.tenant_daily_kpi
    ADD CONSTRAINT uq_tenant_daily_kpi
    UNIQUE (tenant_id, report_date, currency);

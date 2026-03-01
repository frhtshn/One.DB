-- =============================================
-- Core Report - Finance Constraints
-- =============================================

-- client_daily_kpi -> unique (client, date, currency)
ALTER TABLE finance_report.client_daily_kpi
    ADD CONSTRAINT uq_client_daily_kpi
    UNIQUE (client_id, report_date, currency);

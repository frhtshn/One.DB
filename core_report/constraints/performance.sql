-- =============================================
-- Core Report - Performance Constraints
-- =============================================

-- provider_global_daily -> unique (provider, date, currency)
ALTER TABLE performance.provider_global_daily
    ADD CONSTRAINT uq_provider_global_daily
    UNIQUE (provider_id, report_date, currency);

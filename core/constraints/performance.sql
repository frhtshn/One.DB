-- =============================================
-- Core Report - Performance Constraints
-- =============================================

-- provider_global_daily -> unique (provider, date, currency)
ALTER TABLE performance.provider_global_daily
    ADD CONSTRAINT uq_provider_global_daily
    UNIQUE (provider_id, report_date, currency);

-- payment_global_daily -> unique (method, date, currency)
ALTER TABLE performance.payment_global_daily
    ADD CONSTRAINT uq_payment_global_daily
    UNIQUE (method_id, report_date, currency);

-- tenant_traffic_hourly -> unique (tenant, hour)
ALTER TABLE performance.tenant_traffic_hourly
    ADD CONSTRAINT uq_tenant_traffic_hourly
    UNIQUE (tenant_id, period_hour);

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

-- client_traffic_hourly -> unique (client, hour)
ALTER TABLE performance.client_traffic_hourly
    ADD CONSTRAINT uq_client_traffic_hourly
    UNIQUE (client_id, period_hour);

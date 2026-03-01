-- =============================================
-- Finance Log - Constraints
-- =============================================

-- provider_api_requests
ALTER TABLE finance_log.provider_api_requests
    ADD CONSTRAINT chk_fin_api_req_status
    CHECK (status IN ('pending', 'success', 'failed', 'timeout', 'error'));

ALTER TABLE finance_log.provider_api_requests
    ADD CONSTRAINT chk_fin_api_req_method
    CHECK (api_method IN ('GET', 'POST', 'PUT', 'PATCH', 'DELETE'));

-- provider_api_requests — performans alanları
ALTER TABLE finance_log.provider_api_requests
    ADD CONSTRAINT chk_fin_api_req_response_time
    CHECK (response_time_ms IS NULL OR response_time_ms >= 0);

ALTER TABLE finance_log.provider_api_requests
    ADD CONSTRAINT chk_fin_api_req_http_status
    CHECK (http_status_code IS NULL OR http_status_code BETWEEN 100 AND 599);

-- provider_api_callbacks
ALTER TABLE finance_log.provider_api_callbacks
    ADD CONSTRAINT chk_fin_api_cb_status
    CHECK (processing_status IN ('received', 'processing', 'processed', 'failed', 'rejected', 'duplicate'));

ALTER TABLE finance_log.provider_api_callbacks
    ADD CONSTRAINT chk_fin_api_cb_processing_time
    CHECK (processing_time_ms IS NULL OR processing_time_ms >= 0);

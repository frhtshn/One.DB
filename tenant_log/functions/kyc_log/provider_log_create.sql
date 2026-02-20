-- ================================================================
-- PROVIDER_LOG_CREATE: KYC provider API log kaydı
-- ================================================================
-- KYC servis sağlayıcı API çağrı loglarını kaydeder.
-- İstek/yanıt payload'ları JSONB olarak saklanır.
-- Partitioned tablo (created_at üzerinden).
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc_log.provider_log_create(BIGINT, BIGINT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, JSONB, JSONB, VARCHAR, INT, TEXT, INT);

CREATE OR REPLACE FUNCTION kyc_log.provider_log_create(
    p_player_id          BIGINT,
    p_kyc_case_id        BIGINT,
    p_provider_code      VARCHAR(50),
    p_provider_reference VARCHAR(100) DEFAULT NULL,
    p_api_endpoint       VARCHAR(255) DEFAULT NULL,
    p_api_method         VARCHAR(10) DEFAULT NULL,
    p_request_payload    JSONB DEFAULT NULL,
    p_response_payload   JSONB DEFAULT NULL,
    p_status             VARCHAR(30) DEFAULT NULL,
    p_http_status_code   INT DEFAULT NULL,
    p_error_message      TEXT DEFAULT NULL,
    p_response_time_ms   INT DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-provider-log.player-required';
    END IF;

    IF p_kyc_case_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-provider-log.case-required';
    END IF;

    IF p_provider_code IS NULL OR TRIM(p_provider_code) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-provider-log.provider-required';
    END IF;

    INSERT INTO kyc_log.player_kyc_provider_logs (
        player_id, kyc_case_id, provider_code, provider_reference,
        api_endpoint, api_method, request_payload, response_payload,
        status, http_status_code, error_message, response_time_ms
    ) VALUES (
        p_player_id, p_kyc_case_id, p_provider_code, p_provider_reference,
        p_api_endpoint, p_api_method, p_request_payload, p_response_payload,
        p_status, p_http_status_code, p_error_message, p_response_time_ms
    )
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION kyc_log.provider_log_create IS 'Records KYC provider API call logs with request/response payloads. Partitioned table.';

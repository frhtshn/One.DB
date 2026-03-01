-- ================================================================
-- PROVIDER_LOG_LIST: KYC provider log listesi
-- ================================================================
-- Sayfalı, filtrelenebilir provider API log listesi.
-- Partitioned tablo üzerinde çalışır.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc_log.provider_log_list(BIGINT, BIGINT, VARCHAR, VARCHAR, INT, INT);

CREATE OR REPLACE FUNCTION kyc_log.provider_log_list(
    p_player_id     BIGINT DEFAULT NULL,
    p_kyc_case_id   BIGINT DEFAULT NULL,
    p_provider_code VARCHAR(50) DEFAULT NULL,
    p_status        VARCHAR(30) DEFAULT NULL,
    p_page          INT DEFAULT 1,
    p_page_size     INT DEFAULT 20
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_offset INT;
    v_total  BIGINT;
    v_items  JSONB;
BEGIN
    v_offset := (p_page - 1) * p_page_size;

    SELECT COUNT(*)
    INTO v_total
    FROM kyc_log.player_kyc_provider_logs l
    WHERE (p_player_id IS NULL OR l.player_id = p_player_id)
      AND (p_kyc_case_id IS NULL OR l.kyc_case_id = p_kyc_case_id)
      AND (p_provider_code IS NULL OR l.provider_code = p_provider_code)
      AND (p_status IS NULL OR l.status = p_status);

    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', l.id,
            'playerId', l.player_id,
            'kycCaseId', l.kyc_case_id,
            'providerCode', l.provider_code,
            'providerReference', l.provider_reference,
            'apiEndpoint', l.api_endpoint,
            'apiMethod', l.api_method,
            'status', l.status,
            'httpStatusCode', l.http_status_code,
            'errorMessage', l.error_message,
            'responseTimeMs', l.response_time_ms,
            'createdAt', l.created_at
        ) ORDER BY l.created_at DESC
    ), '[]'::jsonb)
    INTO v_items
    FROM kyc_log.player_kyc_provider_logs l
    WHERE (p_player_id IS NULL OR l.player_id = p_player_id)
      AND (p_kyc_case_id IS NULL OR l.kyc_case_id = p_kyc_case_id)
      AND (p_provider_code IS NULL OR l.provider_code = p_provider_code)
      AND (p_status IS NULL OR l.status = p_status)
    ORDER BY l.created_at DESC
    LIMIT p_page_size OFFSET v_offset;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total,
        'page', p_page,
        'pageSize', p_page_size
    );
END;
$$;

COMMENT ON FUNCTION kyc_log.provider_log_list IS 'Paginated KYC provider API logs with filters: player, case, provider, status.';

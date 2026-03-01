-- ================================================================
-- SCREENING_RESULT_CREATE: Tarama sonucu kaydet
-- ================================================================
-- PEP, yaptırım veya diğer tarama sonuçlarını kaydeder.
-- Provider yanıtı JSONB olarak saklanır.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc_audit.screening_result_create(BIGINT, BIGINT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, VARCHAR, INT, INT, JSONB, JSONB, TIMESTAMP, TIMESTAMP);

CREATE OR REPLACE FUNCTION kyc_audit.screening_result_create(
    p_player_id          BIGINT,
    p_kyc_case_id        BIGINT DEFAULT NULL,
    p_screening_type     VARCHAR(30) DEFAULT NULL,
    p_provider_code      VARCHAR(50) DEFAULT NULL,
    p_provider_reference VARCHAR(100) DEFAULT NULL,
    p_provider_scan_id   VARCHAR(100) DEFAULT NULL,
    p_result_status      VARCHAR(30) DEFAULT NULL,
    p_match_score        INT DEFAULT NULL,
    p_match_count        INT DEFAULT 0,
    p_matched_entities   JSONB DEFAULT NULL,
    p_raw_response       JSONB DEFAULT NULL,
    p_expires_at         TIMESTAMP DEFAULT NULL,
    p_next_screening_due TIMESTAMP DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-screening.player-required';
    END IF;

    IF p_screening_type IS NULL OR TRIM(p_screening_type) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-screening.type-required';
    END IF;

    IF p_provider_code IS NULL OR TRIM(p_provider_code) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-screening.provider-required';
    END IF;

    IF p_result_status IS NULL OR TRIM(p_result_status) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-screening.status-required';
    END IF;

    INSERT INTO kyc_audit.player_screening_results (
        player_id, kyc_case_id, screening_type, provider_code,
        provider_reference, provider_scan_id, result_status,
        match_score, match_count, matched_entities, raw_response,
        expires_at, next_screening_due
    ) VALUES (
        p_player_id, p_kyc_case_id, p_screening_type, p_provider_code,
        p_provider_reference, p_provider_scan_id, p_result_status,
        p_match_score, COALESCE(p_match_count, 0), p_matched_entities, p_raw_response,
        p_expires_at, p_next_screening_due
    )
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION kyc_audit.screening_result_create IS 'Records a screening result (PEP, sanctions, etc.) with provider response stored as JSONB.';

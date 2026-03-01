-- ================================================================
-- SCREENING_RESULT_GET: Tarama sonucu detayı
-- ================================================================
-- Tek tarama sonucunun tüm detayını döner.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc_audit.screening_result_get(BIGINT);

CREATE OR REPLACE FUNCTION kyc_audit.screening_result_get(
    p_screening_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_screening_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-screening.screening-required';
    END IF;

    SELECT jsonb_build_object(
        'id', s.id,
        'playerId', s.player_id,
        'kycCaseId', s.kyc_case_id,
        'screeningType', s.screening_type,
        'providerCode', s.provider_code,
        'providerReference', s.provider_reference,
        'providerScanId', s.provider_scan_id,
        'resultStatus', s.result_status,
        'matchScore', s.match_score,
        'matchCount', s.match_count,
        'matchedEntities', s.matched_entities,
        'rawResponse', s.raw_response,
        'reviewStatus', s.review_status,
        'reviewDecision', s.review_decision,
        'reviewedBy', s.reviewed_by,
        'reviewedAt', s.reviewed_at,
        'reviewNotes', s.review_notes,
        'screenedAt', s.screened_at,
        'expiresAt', s.expires_at,
        'nextScreeningDue', s.next_screening_due,
        'createdAt', s.created_at
    )
    INTO v_result
    FROM kyc_audit.player_screening_results s
    WHERE s.id = p_screening_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-screening.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION kyc_audit.screening_result_get IS 'Returns complete screening result detail including review information.';

-- ================================================================
-- DOCUMENT_ANALYSIS_LIST_BY_CASE: Case'e ait tüm analizler
-- ================================================================
-- Case'teki tüm belgelerin tüm analiz sonuçlarını döner.
-- document_id ile gruplanmış. BO operatör ekranı bu fonksiyonu kullanır.
-- ================================================================

DROP FUNCTION IF EXISTS kyc.document_analysis_list_by_case(BIGINT);

CREATE OR REPLACE FUNCTION kyc.document_analysis_list_by_case(
    p_kyc_case_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_kyc_case_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-case.case-required';
    END IF;

    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', a.id,
            'playerId', a.player_id,
            'documentId', a.document_id,
            'requestId', a.request_id,
            'jobId', a.job_id,
            'analysisType', a.analysis_type,
            'idmDocumentType', a.idm_document_type,
            'faceDetectedDoc', a.face_detected_doc,
            'faceDetectedSelfie', a.face_detected_selfie,
            'documentCheck', a.document_check,
            'similarityScore', a.similarity_score,
            'livenessScore', a.liveness_score,
            'addressDocDetails', a.address_doc_details,
            'riskScore', a.risk_score,
            'aiDecision', a.ai_decision,
            'rejectionReasons', a.rejection_reasons,
            'qualityDetails', a.quality_details,
            'processingTimeMs', a.processing_time_ms,
            'analyzedAt', a.analyzed_at,
            'createdAt', a.created_at
        ) ORDER BY a.document_id, a.analyzed_at DESC
    ), '[]'::jsonb)
    INTO v_result
    FROM kyc.document_analysis a
    WHERE a.kyc_case_id = p_kyc_case_id;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION kyc.document_analysis_list_by_case IS 'Returns all analysis records for a KYC case, ordered by document and date. Used by backoffice operator screen.';

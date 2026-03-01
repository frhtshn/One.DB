-- ================================================================
-- DOCUMENT_ANALYSIS_GET: Belgenin analiz sonuçlarını getir
-- ================================================================
-- Belgeye ait tüm analiz kayıtlarını döner (en yeniden eskiye).
-- Birden fazla olabilir (tekrar analiz). Her kayıt idm_document_type
-- içerir; frontend buna göre pipeline panelini render eder.
-- ================================================================

DROP FUNCTION IF EXISTS kyc.document_analysis_get(BIGINT);

CREATE OR REPLACE FUNCTION kyc.document_analysis_get(
    p_document_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_document_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-document.document-required';
    END IF;

    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', a.id,
            'playerId', a.player_id,
            'kycCaseId', a.kyc_case_id,
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
        ) ORDER BY a.analyzed_at DESC
    ), '[]'::jsonb)
    INTO v_result
    FROM kyc.document_analysis a
    WHERE a.document_id = p_document_id;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION kyc.document_analysis_get IS 'Returns all analysis records for a document (newest first). Supports both identity and address pipeline results.';

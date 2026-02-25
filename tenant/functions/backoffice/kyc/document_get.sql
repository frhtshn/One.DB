-- ================================================================
-- DOCUMENT_GET: Doküman detayı getir
-- ================================================================
-- Doküman bilgilerini döner (dosya verisi hariç).
-- Son analiz sonucu ve son operatör kararı dahil.
-- file_data büyük olabilir, ayrı endpoint ile alınır.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.document_get(BIGINT);

CREATE OR REPLACE FUNCTION kyc.document_get(
    p_document_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result          JSONB;
    v_latest_analysis JSONB;
    v_latest_decision JSONB;
    v_analysis_count  INTEGER;
    v_decision_count  INTEGER;
BEGIN
    IF p_document_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-document.document-required';
    END IF;

    SELECT jsonb_build_object(
        'id', d.id,
        'playerId', d.player_id,
        'kycCaseId', d.kyc_case_id,
        'documentType', d.document_type,
        'fileName', d.file_name,
        'mimeType', d.mime_type,
        'storageType', d.storage_type,
        'storagePath', d.storage_path,
        'fileSize', d.file_size,
        'status', d.status,
        'rejectionReason', d.rejection_reason,
        'uploadedAt', d.uploaded_at,
        'reviewedAt', d.reviewed_at,
        'expiresAt', d.expires_at,
        'createdAt', d.created_at
    )
    INTO v_result
    FROM kyc.player_documents d
    WHERE d.id = p_document_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-document.not-found';
    END IF;

    -- Son analiz sonucu
    SELECT jsonb_build_object(
        'id', a.id,
        'idmDocumentType', a.idm_document_type,
        'aiDecision', a.ai_decision,
        'riskScore', a.risk_score,
        'similarityScore', a.similarity_score,
        'livenessScore', a.liveness_score,
        'addressDocDetails', a.address_doc_details,
        'rejectionReasons', a.rejection_reasons,
        'analyzedAt', a.analyzed_at
    )
    INTO v_latest_analysis
    FROM kyc.document_analysis a
    WHERE a.document_id = p_document_id
    ORDER BY a.analyzed_at DESC
    LIMIT 1;

    -- Son operatör kararı
    SELECT jsonb_build_object(
        'id', dd.id,
        'decision', dd.decision,
        'reason', dd.reason,
        'decidedBy', dd.decided_by,
        'decidedAt', dd.decided_at
    )
    INTO v_latest_decision
    FROM kyc.document_decisions dd
    WHERE dd.document_id = p_document_id
    ORDER BY dd.decided_at DESC
    LIMIT 1;

    -- Sayaçlar
    SELECT COUNT(*) INTO v_analysis_count
    FROM kyc.document_analysis WHERE document_id = p_document_id;

    SELECT COUNT(*) INTO v_decision_count
    FROM kyc.document_decisions WHERE document_id = p_document_id;

    -- Sonucu zenginleştir
    v_result := v_result || jsonb_build_object(
        'latestAnalysis', v_latest_analysis,
        'latestDecision', v_latest_decision,
        'analysisCount', v_analysis_count,
        'decisionCount', v_decision_count
    );

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION kyc.document_get IS 'Returns document metadata with latest AI analysis and operator decision. Excludes file_data for performance.';

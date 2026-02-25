-- ================================================================
-- DOCUMENT_DECISION_LIST: Belgenin karar geçmişi
-- ================================================================
-- Belgeye ait tüm operatör kararlarını döner (en yeniden eskiye).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.document_decision_list(BIGINT);

CREATE OR REPLACE FUNCTION kyc.document_decision_list(
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
            'id', dd.id,
            'playerId', dd.player_id,
            'kycCaseId', dd.kyc_case_id,
            'documentId', dd.document_id,
            'analysisId', dd.analysis_id,
            'decision', dd.decision,
            'reason', dd.reason,
            'decidedBy', dd.decided_by,
            'decidedAt', dd.decided_at,
            'createdAt', dd.created_at
        ) ORDER BY dd.decided_at DESC
    ), '[]'::jsonb)
    INTO v_result
    FROM kyc.document_decisions dd
    WHERE dd.document_id = p_document_id;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION kyc.document_decision_list IS 'Returns all operator decisions for a document (newest first).';

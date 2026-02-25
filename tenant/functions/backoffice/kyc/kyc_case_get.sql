-- ================================================================
-- KYC_CASE_GET: KYC case detayını getir
-- ================================================================
-- Case bilgisi, workflow geçmişi ve dokümanları ile birlikte.
-- Her belge için son AI analiz ve operatör karar özeti dahil.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.kyc_case_get(BIGINT);

CREATE OR REPLACE FUNCTION kyc.kyc_case_get(
    p_case_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_case      RECORD;
    v_workflows JSONB;
    v_documents JSONB;
BEGIN
    IF p_case_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-case.case-required';
    END IF;

    -- Case bilgisi (selfie_document_id dahil)
    SELECT kc.id, kc.player_id, kc.current_status, kc.kyc_level,
           kc.risk_level, kc.assigned_reviewer_id, kc.last_decision_reason,
           kc.selfie_document_id,
           kc.created_at, kc.updated_at
    INTO v_case
    FROM kyc.player_kyc_cases kc
    WHERE kc.id = p_case_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-case.not-found';
    END IF;

    -- Workflow geçmişi
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', w.id,
            'previousStatus', w.previous_status,
            'currentStatus', w.current_status,
            'action', w.action,
            'performedBy', w.performed_by,
            'reason', w.reason,
            'createdAt', w.created_at
        ) ORDER BY w.created_at ASC
    ), '[]'::jsonb)
    INTO v_workflows
    FROM kyc.player_kyc_workflows w
    WHERE w.kyc_case_id = p_case_id;

    -- İlgili dokümanlar (son analiz + karar özeti dahil)
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', d.id,
            'documentType', d.document_type,
            'fileName', d.file_name,
            'status', d.status,
            'uploadedAt', d.uploaded_at,
            'reviewedAt', d.reviewed_at,
            'latestAiDecision', la.ai_decision,
            'latestRiskScore', la.risk_score,
            'latestIdmDocumentType', la.idm_document_type,
            'latestOperatorDecision', ld.decision
        ) ORDER BY d.uploaded_at ASC
    ), '[]'::jsonb)
    INTO v_documents
    FROM kyc.player_documents d
    LEFT JOIN LATERAL (
        SELECT a.ai_decision, a.risk_score, a.idm_document_type
        FROM kyc.document_analysis a
        WHERE a.document_id = d.id
        ORDER BY a.analyzed_at DESC
        LIMIT 1
    ) la ON true
    LEFT JOIN LATERAL (
        SELECT dd.decision
        FROM kyc.document_decisions dd
        WHERE dd.document_id = d.id
        ORDER BY dd.decided_at DESC
        LIMIT 1
    ) ld ON true
    WHERE d.kyc_case_id = p_case_id;

    RETURN jsonb_build_object(
        'id', v_case.id,
        'playerId', v_case.player_id,
        'currentStatus', v_case.current_status,
        'kycLevel', v_case.kyc_level,
        'riskLevel', v_case.risk_level,
        'assignedReviewerId', v_case.assigned_reviewer_id,
        'lastDecisionReason', v_case.last_decision_reason,
        'selfieDocumentId', v_case.selfie_document_id,
        'createdAt', v_case.created_at,
        'updatedAt', v_case.updated_at,
        'workflows', v_workflows,
        'documents', v_documents
    );
END;
$$;

COMMENT ON FUNCTION kyc.kyc_case_get IS 'Returns KYC case detail with workflow history, documents including latest AI analysis and operator decision summaries.';

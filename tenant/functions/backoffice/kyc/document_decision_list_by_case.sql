-- ================================================================
-- DOCUMENT_DECISION_LIST_BY_CASE: Case'e ait tüm kararlar
-- ================================================================
-- Case'teki tüm belgelerin karar geçmişini döner.
-- ================================================================

DROP FUNCTION IF EXISTS kyc.document_decision_list_by_case(BIGINT);

CREATE OR REPLACE FUNCTION kyc.document_decision_list_by_case(
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
            'id', dd.id,
            'playerId', dd.player_id,
            'documentId', dd.document_id,
            'analysisId', dd.analysis_id,
            'decision', dd.decision,
            'reason', dd.reason,
            'decidedBy', dd.decided_by,
            'decidedAt', dd.decided_at,
            'createdAt', dd.created_at
        ) ORDER BY dd.document_id, dd.decided_at DESC
    ), '[]'::jsonb)
    INTO v_result
    FROM kyc.document_decisions dd
    WHERE dd.kyc_case_id = p_kyc_case_id;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION kyc.document_decision_list_by_case IS 'Returns all operator decisions for a KYC case, ordered by document and date.';

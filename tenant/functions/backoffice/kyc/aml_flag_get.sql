-- ================================================================
-- AML_FLAG_GET: AML bayrak detayı getir
-- ================================================================
-- Tek AML flag'in tüm detayını döner.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.aml_flag_get(BIGINT);

CREATE OR REPLACE FUNCTION kyc.aml_flag_get(
    p_flag_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_flag_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-aml.flag-required';
    END IF;

    SELECT jsonb_build_object(
        'id', f.id,
        'playerId', f.player_id,
        'flagType', f.flag_type,
        'severity', f.severity,
        'status', f.status,
        'description', f.description,
        'detectionMethod', f.detection_method,
        'ruleId', f.rule_id,
        'ruleName', f.rule_name,
        'relatedTransactions', f.related_transactions,
        'evidenceData', f.evidence_data,
        'thresholdAmount', f.threshold_amount,
        'actualAmount', f.actual_amount,
        'currencyCode', f.currency_code,
        'periodStart', f.period_start,
        'periodEnd', f.period_end,
        'transactionCount', f.transaction_count,
        'assignedTo', f.assigned_to,
        'assignedAt', f.assigned_at,
        'investigatedBy', f.investigated_by,
        'investigationStartedAt', f.investigation_started_at,
        'investigationNotes', f.investigation_notes,
        'decision', f.decision,
        'decisionBy', f.decision_by,
        'decisionAt', f.decision_at,
        'decisionReason', f.decision_reason,
        'sarRequired', f.sar_required,
        'sarReference', f.sar_reference,
        'sarFiledAt', f.sar_filed_at,
        'sarFiledBy', f.sar_filed_by,
        'actionsTaken', f.actions_taken,
        'detectedAt', f.detected_at,
        'closedAt', f.closed_at,
        'createdAt', f.created_at,
        'updatedAt', f.updated_at
    )
    INTO v_result
    FROM kyc.player_aml_flags f
    WHERE f.id = p_flag_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-aml.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION kyc.aml_flag_get IS 'Returns complete AML flag detail including investigation, decision and SAR information.';

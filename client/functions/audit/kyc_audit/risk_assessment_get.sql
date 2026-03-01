-- ================================================================
-- RISK_ASSESSMENT_GET: En son risk değerlendirmesi
-- ================================================================
-- Oyuncunun en son risk değerlendirmesini döner.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc_audit.risk_assessment_get(BIGINT);

CREATE OR REPLACE FUNCTION kyc_audit.risk_assessment_get(
    p_player_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-risk.player-required';
    END IF;

    SELECT jsonb_build_object(
        'id', r.id,
        'playerId', r.player_id,
        'assessmentType', r.assessment_type,
        'riskScore', r.risk_score,
        'riskLevel', r.risk_level,
        'previousRiskLevel', r.previous_risk_level,
        'riskChange', r.risk_change,
        'riskFactors', r.risk_factors,
        'countryRiskScore', r.country_risk_score,
        'occupationRiskScore', r.occupation_risk_score,
        'pepRiskScore', r.pep_risk_score,
        'transactionRiskScore', r.transaction_risk_score,
        'sofRiskScore', r.sof_risk_score,
        'behavioralRiskScore', r.behavioral_risk_score,
        'triggerEvent', r.trigger_event,
        'recommendedActions', r.recommended_actions,
        'assessedBy', r.assessed_by,
        'validUntil', r.valid_until,
        'createdAt', r.created_at
    )
    INTO v_result
    FROM kyc_audit.player_risk_assessments r
    WHERE r.player_id = p_player_id
    ORDER BY r.created_at DESC
    LIMIT 1;

    -- NULL döner (henüz değerlendirme yapılmamış olabilir)
    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION kyc_audit.risk_assessment_get IS 'Returns the latest risk assessment for a player. Returns NULL if no assessment exists.';

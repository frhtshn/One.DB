-- ================================================================
-- RISK_ASSESSMENT_LIST: Risk değerlendirme geçmişi
-- ================================================================
-- Sayfalı risk değerlendirme listesi.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc_audit.risk_assessment_list(BIGINT, VARCHAR, VARCHAR, INT, INT);

CREATE OR REPLACE FUNCTION kyc_audit.risk_assessment_list(
    p_player_id      BIGINT DEFAULT NULL,
    p_risk_level     VARCHAR(20) DEFAULT NULL,
    p_assessment_type VARCHAR(30) DEFAULT NULL,
    p_page           INT DEFAULT 1,
    p_page_size      INT DEFAULT 20
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_offset INT;
    v_total  BIGINT;
    v_items  JSONB;
BEGIN
    v_offset := (p_page - 1) * p_page_size;

    SELECT COUNT(*)
    INTO v_total
    FROM kyc_audit.player_risk_assessments r
    WHERE (p_player_id IS NULL OR r.player_id = p_player_id)
      AND (p_risk_level IS NULL OR r.risk_level = p_risk_level)
      AND (p_assessment_type IS NULL OR r.assessment_type = p_assessment_type);

    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', r.id,
            'playerId', r.player_id,
            'assessmentType', r.assessment_type,
            'riskScore', r.risk_score,
            'riskLevel', r.risk_level,
            'previousRiskLevel', r.previous_risk_level,
            'riskChange', r.risk_change,
            'assessedBy', r.assessed_by,
            'validUntil', r.valid_until,
            'createdAt', r.created_at
        ) ORDER BY r.created_at DESC
    ), '[]'::jsonb)
    INTO v_items
    FROM kyc_audit.player_risk_assessments r
    WHERE (p_player_id IS NULL OR r.player_id = p_player_id)
      AND (p_risk_level IS NULL OR r.risk_level = p_risk_level)
      AND (p_assessment_type IS NULL OR r.assessment_type = p_assessment_type)
    ORDER BY r.created_at DESC
    LIMIT p_page_size OFFSET v_offset;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total,
        'page', p_page,
        'pageSize', p_page_size
    );
END;
$$;

COMMENT ON FUNCTION kyc_audit.risk_assessment_list IS 'Paginated risk assessment history with filters: player, risk level, assessment type.';

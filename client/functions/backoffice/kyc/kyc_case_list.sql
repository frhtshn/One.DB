-- ================================================================
-- KYC_CASE_LIST: KYC case listesi
-- ================================================================
-- Sayfalı, filtrelenebilir KYC case listesi.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.kyc_case_list(VARCHAR, VARCHAR, VARCHAR, BIGINT, BIGINT, INT, INT);

CREATE OR REPLACE FUNCTION kyc.kyc_case_list(
    p_status      VARCHAR(30) DEFAULT NULL,
    p_kyc_level   VARCHAR(20) DEFAULT NULL,
    p_risk_level  VARCHAR(20) DEFAULT NULL,
    p_reviewer_id BIGINT DEFAULT NULL,
    p_player_id   BIGINT DEFAULT NULL,
    p_page        INT DEFAULT 1,
    p_page_size   INT DEFAULT 20
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

    -- Toplam sayı
    SELECT COUNT(*)
    INTO v_total
    FROM kyc.player_kyc_cases kc
    WHERE (p_status IS NULL OR kc.current_status = p_status)
      AND (p_kyc_level IS NULL OR kc.kyc_level = p_kyc_level)
      AND (p_risk_level IS NULL OR kc.risk_level = p_risk_level)
      AND (p_reviewer_id IS NULL OR kc.assigned_reviewer_id = p_reviewer_id)
      AND (p_player_id IS NULL OR kc.player_id = p_player_id);

    -- Sayfalı liste (subquery ile pagination, dışarıda jsonb_agg)
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', sub.id,
            'playerId', sub.player_id,
            'currentStatus', sub.current_status,
            'kycLevel', sub.kyc_level,
            'riskLevel', sub.risk_level,
            'assignedReviewerId', sub.assigned_reviewer_id,
            'lastDecisionReason', sub.last_decision_reason,
            'createdAt', sub.created_at,
            'updatedAt', sub.updated_at
        )
    ), '[]'::jsonb)
    INTO v_items
    FROM (
        SELECT kc.id, kc.player_id, kc.current_status, kc.kyc_level,
               kc.risk_level, kc.assigned_reviewer_id, kc.last_decision_reason,
               kc.created_at, kc.updated_at
        FROM kyc.player_kyc_cases kc
        WHERE (p_status IS NULL OR kc.current_status = p_status)
          AND (p_kyc_level IS NULL OR kc.kyc_level = p_kyc_level)
          AND (p_risk_level IS NULL OR kc.risk_level = p_risk_level)
          AND (p_reviewer_id IS NULL OR kc.assigned_reviewer_id = p_reviewer_id)
          AND (p_player_id IS NULL OR kc.player_id = p_player_id)
        ORDER BY kc.created_at DESC
        LIMIT p_page_size OFFSET v_offset
    ) sub;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total,
        'page', p_page,
        'pageSize', p_page_size
    );
END;
$$;

COMMENT ON FUNCTION kyc.kyc_case_list IS 'Paginated KYC case list with filters: status, level, risk, reviewer, player.';

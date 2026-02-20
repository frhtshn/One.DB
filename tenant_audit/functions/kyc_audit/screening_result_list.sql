-- ================================================================
-- SCREENING_RESULT_LIST: Tarama sonuçları listesi
-- ================================================================
-- Sayfalı, filtrelenebilir tarama sonuçları.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc_audit.screening_result_list(BIGINT, VARCHAR, VARCHAR, VARCHAR, INT, INT);

CREATE OR REPLACE FUNCTION kyc_audit.screening_result_list(
    p_player_id      BIGINT DEFAULT NULL,
    p_screening_type VARCHAR(30) DEFAULT NULL,
    p_result_status  VARCHAR(30) DEFAULT NULL,
    p_review_status  VARCHAR(20) DEFAULT NULL,
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
    FROM kyc_audit.player_screening_results s
    WHERE (p_player_id IS NULL OR s.player_id = p_player_id)
      AND (p_screening_type IS NULL OR s.screening_type = p_screening_type)
      AND (p_result_status IS NULL OR s.result_status = p_result_status)
      AND (p_review_status IS NULL OR s.review_status = p_review_status);

    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', s.id,
            'playerId', s.player_id,
            'screeningType', s.screening_type,
            'providerCode', s.provider_code,
            'resultStatus', s.result_status,
            'matchScore', s.match_score,
            'matchCount', s.match_count,
            'reviewStatus', s.review_status,
            'reviewDecision', s.review_decision,
            'screenedAt', s.screened_at,
            'expiresAt', s.expires_at
        ) ORDER BY s.screened_at DESC
    ), '[]'::jsonb)
    INTO v_items
    FROM kyc_audit.player_screening_results s
    WHERE (p_player_id IS NULL OR s.player_id = p_player_id)
      AND (p_screening_type IS NULL OR s.screening_type = p_screening_type)
      AND (p_result_status IS NULL OR s.result_status = p_result_status)
      AND (p_review_status IS NULL OR s.review_status = p_review_status)
    ORDER BY s.screened_at DESC
    LIMIT p_page_size OFFSET v_offset;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total,
        'page', p_page,
        'pageSize', p_page_size
    );
END;
$$;

COMMENT ON FUNCTION kyc_audit.screening_result_list IS 'Paginated screening results with filters: player, type, status, review status.';

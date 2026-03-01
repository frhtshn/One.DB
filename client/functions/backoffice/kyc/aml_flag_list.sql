-- ================================================================
-- AML_FLAG_LIST: AML bayrak listesi
-- ================================================================
-- Sayfalı, filtrelenebilir AML flag listesi.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.aml_flag_list(BIGINT, VARCHAR, VARCHAR, VARCHAR, BIGINT, INT, INT);

CREATE OR REPLACE FUNCTION kyc.aml_flag_list(
    p_player_id   BIGINT DEFAULT NULL,
    p_status      VARCHAR(30) DEFAULT NULL,
    p_severity    VARCHAR(20) DEFAULT NULL,
    p_flag_type   VARCHAR(50) DEFAULT NULL,
    p_assigned_to BIGINT DEFAULT NULL,
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

    SELECT COUNT(*)
    INTO v_total
    FROM kyc.player_aml_flags f
    WHERE (p_player_id IS NULL OR f.player_id = p_player_id)
      AND (p_status IS NULL OR f.status = p_status)
      AND (p_severity IS NULL OR f.severity = p_severity)
      AND (p_flag_type IS NULL OR f.flag_type = p_flag_type)
      AND (p_assigned_to IS NULL OR f.assigned_to = p_assigned_to);

    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', f.id,
            'playerId', f.player_id,
            'flagType', f.flag_type,
            'severity', f.severity,
            'status', f.status,
            'description', f.description,
            'detectionMethod', f.detection_method,
            'assignedTo', f.assigned_to,
            'decision', f.decision,
            'detectedAt', f.detected_at,
            'closedAt', f.closed_at
        ) ORDER BY f.detected_at DESC
    ), '[]'::jsonb)
    INTO v_items
    FROM kyc.player_aml_flags f
    WHERE (p_player_id IS NULL OR f.player_id = p_player_id)
      AND (p_status IS NULL OR f.status = p_status)
      AND (p_severity IS NULL OR f.severity = p_severity)
      AND (p_flag_type IS NULL OR f.flag_type = p_flag_type)
      AND (p_assigned_to IS NULL OR f.assigned_to = p_assigned_to)
    ORDER BY f.detected_at DESC
    LIMIT p_page_size OFFSET v_offset;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total,
        'page', p_page,
        'pageSize', p_page_size
    );
END;
$$;

COMMENT ON FUNCTION kyc.aml_flag_list IS 'Paginated AML flag list with filters: player, status, severity, type, assignee.';

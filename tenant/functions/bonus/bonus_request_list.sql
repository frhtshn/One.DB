-- ================================================================
-- BONUS_REQUEST_LIST: Bonus talep listesi (filtrelemeli + sayfalı)
-- ================================================================
-- Status, kaynak, oyuncu, atanan operatör, tip ve öncelik
-- bazında filtreleme destekler. Sayfalama ile sonuç döner.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_request_list(VARCHAR, VARCHAR, BIGINT, BIGINT, VARCHAR, SMALLINT, INT, INT);

CREATE OR REPLACE FUNCTION bonus.bonus_request_list(
    p_status            VARCHAR(20) DEFAULT NULL,
    p_request_source    VARCHAR(20) DEFAULT NULL,
    p_player_id         BIGINT DEFAULT NULL,
    p_assigned_to_id    BIGINT DEFAULT NULL,
    p_request_type      VARCHAR(50) DEFAULT NULL,
    p_priority          SMALLINT DEFAULT NULL,
    p_page              INT DEFAULT 1,
    p_page_size         INT DEFAULT 20
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_offset    INT;
    v_total     BIGINT;
    v_items     JSONB;
BEGIN
    v_offset := (GREATEST(p_page, 1) - 1) * p_page_size;

    -- Toplam sayı
    SELECT COUNT(*) INTO v_total
    FROM bonus.bonus_requests r
    WHERE (p_status IS NULL OR r.status = p_status)
      AND (p_request_source IS NULL OR r.request_source = p_request_source)
      AND (p_player_id IS NULL OR r.player_id = p_player_id)
      AND (p_assigned_to_id IS NULL OR r.assigned_to_id = p_assigned_to_id)
      AND (p_request_type IS NULL OR r.request_type = p_request_type)
      AND (p_priority IS NULL OR r.priority = p_priority);

    -- Sonuçları al
    SELECT COALESCE(jsonb_agg(sub.item), '[]'::JSONB)
    INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'id', r.id,
            'playerId', r.player_id,
            'requestSource', r.request_source,
            'requestType', r.request_type,
            'requestedAmount', r.requested_amount,
            'currency', r.currency,
            'description', LEFT(r.description, 200),
            'status', r.status,
            'priority', r.priority,
            'assignedToId', r.assigned_to_id,
            'assignedAt', r.assigned_at,
            'reviewedById', r.reviewed_by_id,
            'reviewNote', r.review_note,
            'approvedAmount', r.approved_amount,
            'bonusAwardId', r.bonus_award_id,
            'requestedById', r.requested_by_id,
            'expiresAt', r.expires_at,
            'createdAt', r.created_at
        ) AS item
        FROM bonus.bonus_requests r
        WHERE (p_status IS NULL OR r.status = p_status)
          AND (p_request_source IS NULL OR r.request_source = p_request_source)
          AND (p_player_id IS NULL OR r.player_id = p_player_id)
          AND (p_assigned_to_id IS NULL OR r.assigned_to_id = p_assigned_to_id)
          AND (p_request_type IS NULL OR r.request_type = p_request_type)
          AND (p_priority IS NULL OR r.priority = p_priority)
        ORDER BY r.created_at DESC
        LIMIT p_page_size
        OFFSET v_offset
    ) sub;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total,
        'page', GREATEST(p_page, 1),
        'pageSize', p_page_size
    );
END;
$$;

COMMENT ON FUNCTION bonus.bonus_request_list IS 'Lists bonus requests with optional filtering by status, source, player, assignee, type, and priority. Paginated results.';

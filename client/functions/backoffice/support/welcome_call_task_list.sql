-- ================================================================
-- WELCOME_CALL_TASK_LIST: Hoşgeldin araması görev listesi
-- ================================================================
-- Call center kuyruk yönetimi için görev listesi.
-- Pending: created_at ASC (eski kayıtlar önce).
-- Rescheduled: next_attempt_at ASC.
-- Opsiyonel status ve atama filtresi.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.welcome_call_task_list(VARCHAR, BIGINT, INT, INT);

CREATE OR REPLACE FUNCTION support.welcome_call_task_list(
    p_status        VARCHAR(20) DEFAULT NULL,
    p_assigned_to_id BIGINT DEFAULT NULL,
    p_page          INT DEFAULT 1,
    p_page_size     INT DEFAULT 20
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
    FROM support.welcome_call_tasks wct
    WHERE (p_status IS NULL OR wct.status = p_status)
      AND (p_assigned_to_id IS NULL OR wct.assigned_to_id = p_assigned_to_id);

    -- Sonuçları al
    SELECT COALESCE(jsonb_agg(sub.item), '[]'::JSONB)
    INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'id', wct.id,
            'playerId', wct.player_id,
            'status', wct.status,
            'assignedToId', wct.assigned_to_id,
            'assignedAt', wct.assigned_at,
            'callResult', wct.call_result,
            'callNotes', wct.call_notes,
            'callDurationSeconds', wct.call_duration_seconds,
            'attemptCount', wct.attempt_count,
            'maxAttempts', wct.max_attempts,
            'nextAttemptAt', wct.next_attempt_at,
            'completedAt', wct.completed_at,
            'createdAt', wct.created_at,
            'updatedAt', wct.updated_at
        ) AS item
        FROM support.welcome_call_tasks wct
        WHERE (p_status IS NULL OR wct.status = p_status)
          AND (p_assigned_to_id IS NULL OR wct.assigned_to_id = p_assigned_to_id)
        ORDER BY
            CASE WHEN wct.status = 'rescheduled' THEN wct.next_attempt_at
                 ELSE wct.created_at
            END ASC
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

COMMENT ON FUNCTION support.welcome_call_task_list IS 'Lists welcome call tasks for queue management. Pending tasks sorted by creation date, rescheduled by next attempt time.';

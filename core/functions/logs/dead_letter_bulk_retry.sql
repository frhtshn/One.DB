CREATE OR REPLACE FUNCTION logs.dead_letter_bulk_retry(
    p_ids UUID[],
    p_performed_by VARCHAR(255),
    p_max_retry INT DEFAULT 10
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_success_count INT;
    v_total_requested INT;
BEGIN
    IF array_length(p_ids, 1) > 500 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.deadletter.bulklimitexceeded';
    END IF;

    v_total_requested := COALESCE(array_length(p_ids, 1), 0);

    INSERT INTO logs.dead_letter_audit
        (dead_letter_id, event_type, event_id, action, performed_by, old_status, new_status)
    SELECT id, event_type, event_id, 'bulk_retry', p_performed_by, status, 'pending'
    FROM logs.dead_letter_messages
    WHERE id = ANY(p_ids)
      AND status IN ('pending', 'failed', 'max_retry_exceeded')
      AND manual_retry_count < p_max_retry
      AND is_archived = FALSE;

    UPDATE logs.dead_letter_messages
    SET status = 'pending',
        manual_retry_count = manual_retry_count + 1,
        next_retry_at = NOW(),
        updated_at = NOW()
    WHERE id = ANY(p_ids)
      AND status IN ('pending', 'failed', 'max_retry_exceeded')
      AND manual_retry_count < p_max_retry
      AND is_archived = FALSE;

    GET DIAGNOSTICS v_success_count = ROW_COUNT;

    RETURN jsonb_build_object(
        'successCount', v_success_count,
        'skipCount', v_total_requested - v_success_count,
        'totalRequested', v_total_requested
    );
END;
$$;

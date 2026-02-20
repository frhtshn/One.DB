CREATE OR REPLACE FUNCTION logs.dead_letter_schedule_retry(
    p_id UUID,
    p_next_retry_at TIMESTAMPTZ,
    p_performed_by VARCHAR(255) DEFAULT 'system'
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_event_type VARCHAR(255);
    v_event_id VARCHAR(255);
    v_updated INT;
BEGIN
    UPDATE logs.dead_letter_messages
    SET status = 'pending',
        next_retry_at = p_next_retry_at,
        retry_count = retry_count + 1,
        updated_at = NOW()
    WHERE id = p_id
      AND status IN ('pending', 'retrying')
      AND is_archived = FALSE;

    GET DIAGNOSTICS v_updated = ROW_COUNT;
    IF v_updated = 0 THEN RETURN; END IF;

    SELECT event_type, event_id INTO v_event_type, v_event_id
    FROM logs.dead_letter_messages WHERE id = p_id;

    INSERT INTO logs.dead_letter_audit
        (dead_letter_id, event_type, event_id, action, performed_by, notes)
    VALUES (p_id, v_event_type, v_event_id, 'schedule_retry', p_performed_by,
            'Scheduled: ' || p_next_retry_at::TEXT);
END;
$$;

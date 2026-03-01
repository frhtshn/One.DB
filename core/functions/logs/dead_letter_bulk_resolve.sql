CREATE OR REPLACE FUNCTION logs.dead_letter_bulk_resolve(
    p_ids UUID[],
    p_resolved_by VARCHAR(255),
    p_notes TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_affected INT;
    v_total_requested INT;
BEGIN
    IF array_length(p_ids, 1) > 500 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.deadletter.bulklimitexceeded';
    END IF;

    v_total_requested := COALESCE(array_length(p_ids, 1), 0);

    INSERT INTO logs.dead_letter_audit
        (dead_letter_id, event_type, event_id, action, performed_by, old_status, new_status, notes)
    SELECT id, event_type, event_id, 'bulk_resolve', p_resolved_by, status, 'resolved', p_notes
    FROM logs.dead_letter_messages
    WHERE id = ANY(p_ids)
      AND status IN ('pending', 'retrying', 'failed', 'validation_failed', 'max_retry_exceeded', 'ignored')
      AND is_archived = FALSE;

    UPDATE logs.dead_letter_messages
    SET status = 'resolved', resolved_at = NOW(), resolved_by = p_resolved_by,
        resolution_notes = COALESCE(p_notes, resolution_notes),
        next_retry_at = NULL, updated_at = NOW()
    WHERE id = ANY(p_ids)
      AND status IN ('pending', 'retrying', 'failed', 'validation_failed', 'max_retry_exceeded', 'ignored')
      AND is_archived = FALSE;

    GET DIAGNOSTICS v_affected = ROW_COUNT;

    RETURN jsonb_build_object(
        'successCount', v_affected,
        'skipCount', v_total_requested - v_affected,
        'totalRequested', v_total_requested
    );
END;
$$;

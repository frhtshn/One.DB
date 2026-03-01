CREATE OR REPLACE FUNCTION logs.dead_letter_archive(
    p_before_date TIMESTAMPTZ,
    p_statuses VARCHAR(50)[] DEFAULT ARRAY['resolved', 'failed', 'ignored'],
    p_performed_by VARCHAR(255) DEFAULT 'system'
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_affected INT;
BEGIN
    INSERT INTO logs.dead_letter_audit
        (dead_letter_id, event_type, event_id, action, performed_by, old_status, new_status)
    SELECT id, event_type, event_id, 'archive', p_performed_by, status, 'archived'
    FROM logs.dead_letter_messages
    WHERE created_at < p_before_date AND status = ANY(p_statuses) AND is_archived = FALSE;

    UPDATE logs.dead_letter_messages
    SET status = 'archived', is_archived = TRUE, archived_at = NOW(),
        next_retry_at = NULL, updated_at = NOW()
    WHERE created_at < p_before_date AND status = ANY(p_statuses) AND is_archived = FALSE;

    GET DIAGNOSTICS v_affected = ROW_COUNT;

    RETURN jsonb_build_object(
        'archivedCount', v_affected,
        'beforeDate', p_before_date,
        'statuses', to_jsonb(p_statuses)
    );
END;
$$;

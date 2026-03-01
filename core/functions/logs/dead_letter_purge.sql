CREATE OR REPLACE FUNCTION logs.dead_letter_purge(
    p_before_date TIMESTAMPTZ,
    p_only_archived BOOLEAN DEFAULT TRUE
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_dl_count INT;
    v_audit_count INT;
BEGIN
    DELETE FROM logs.dead_letter_audit
    WHERE dead_letter_id IN (
        SELECT id FROM logs.dead_letter_messages
        WHERE created_at < p_before_date
          AND (p_only_archived = FALSE OR is_archived = TRUE)
    );
    GET DIAGNOSTICS v_audit_count = ROW_COUNT;

    DELETE FROM logs.dead_letter_messages
    WHERE created_at < p_before_date
      AND (p_only_archived = FALSE OR is_archived = TRUE);
    GET DIAGNOSTICS v_dl_count = ROW_COUNT;

    RETURN jsonb_build_object(
        'deletedDeadLetters', v_dl_count,
        'deletedAuditRecords', v_audit_count,
        'beforeDate', p_before_date,
        'onlyArchived', p_only_archived
    );
END;
$$;

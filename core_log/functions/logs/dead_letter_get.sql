DROP FUNCTION IF EXISTS logs.dead_letter_get(UUID);

-- Get dead letter by ID
CREATE OR REPLACE FUNCTION logs.dead_letter_get(
    p_id UUID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'id', m.id,
        'eventId', m.event_id,
        'eventType', m.event_type,
        'tenantId', m.tenant_id,
        'payload', m.payload,
        'exceptionMessage', m.exception_message,
        'exceptionStackTrace', m.exception_stack_trace,
        'retryCount', m.retry_count,
        'status', m.status,
        'createdAt', m.created_at,
        'updatedAt', m.updated_at,
        'resolvedAt', m.resolved_at,
        'resolvedBy', m.resolved_by,
        'resolutionNotes', m.resolution_notes
    ) INTO v_result
    FROM logs.dead_letter_messages m
    WHERE m.id = p_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.logs.deadletternotfound';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION logs.dead_letter_get IS 'Gets dead letter details by ID';

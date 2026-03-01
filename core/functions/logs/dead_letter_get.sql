DROP FUNCTION IF EXISTS logs.dead_letter_get(UUID);

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
        'resolutionNotes', m.resolution_notes,
        'clusterId', m.cluster_id,
        'consumerName', m.consumer_name,
        'originalEventId', m.original_event_id,
        'manualRetryCount', m.manual_retry_count,
        'failureCategory', m.failure_category,
        'correlationId', m.correlation_id,
        'isArchived', m.is_archived,
        'archivedAt', m.archived_at,
        'nextRetryAt', m.next_retry_at
    ) INTO v_result
    FROM logs.dead_letter_messages m
    WHERE m.id = p_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.deadletter.notfound';
    END IF;

    RETURN v_result;
END;
$$;

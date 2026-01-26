DROP FUNCTION IF EXISTS logs.dead_letter_list_pending(INT);

-- Get pending dead letters for retry
CREATE OR REPLACE FUNCTION logs.dead_letter_list_pending(
    p_limit INT DEFAULT 100
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(
        jsonb_agg(
            jsonb_build_object(
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
                'updatedAt', m.updated_at
            )
            ORDER BY m.created_at ASC
        ),
        '[]'::JSONB
    ) INTO v_result
    FROM logs.dead_letter_messages m
    WHERE m.status IN ('pending', 'retrying')
    LIMIT p_limit;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION logs.dead_letter_list_pending IS 'Retrieves pending dead letters for processing';

CREATE OR REPLACE FUNCTION logs.dead_letter_get_for_auto_retry(
    p_limit INT DEFAULT 50,
    p_max_retry INT DEFAULT 10
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    WITH candidates AS (
        SELECT id
        FROM logs.dead_letter_messages
        WHERE status = 'pending'
          AND is_archived = FALSE
          AND retry_count < p_max_retry
          AND (failure_category IS NULL
               OR failure_category NOT IN ('validation', 'serialization', 'authorization'))
          AND (
              (next_retry_at IS NOT NULL AND next_retry_at <= NOW())
              OR
              (next_retry_at IS NULL AND created_at <= NOW() - INTERVAL '5 minutes')
          )
        ORDER BY next_retry_at ASC NULLS FIRST
        LIMIT p_limit
        FOR UPDATE SKIP LOCKED
    ),
    claimed AS (
        UPDATE logs.dead_letter_messages m
        SET status = 'retrying', updated_at = NOW()
        FROM candidates c
        WHERE m.id = c.id
        RETURNING m.id, m.event_id, m.event_type, m.client_id, m.payload,
                  m.retry_count, m.failure_category, m.original_event_id, m.correlation_id
    )
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', id, 'eventId', event_id, 'eventType', event_type,
        'clientId', client_id, 'payload', payload,
        'retryCount', retry_count, 'failureCategory', failure_category,
        'originalEventId', original_event_id, 'correlationId', correlation_id
    )), '[]'::JSONB)
    INTO v_result
    FROM claimed;

    RETURN v_result;
END;
$$;

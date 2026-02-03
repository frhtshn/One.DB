-- ================================================================
-- OUTBOX_STATS - İstatistikler
-- ================================================================

CREATE OR REPLACE FUNCTION outbox.outbox_stats()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'total_count', COUNT(*),
        'pending_count', COUNT(*) FILTER (WHERE status = 'pending'),
        'processing_count', COUNT(*) FILTER (WHERE status = 'processing'),
        'completed_count', COUNT(*) FILTER (WHERE status = 'completed'),
        'failed_count', COUNT(*) FILTER (WHERE status = 'failed'),
        'retryable_count', COUNT(*) FILTER (WHERE status = 'failed' AND retry_count < max_retries),
        'oldest_pending', MIN(created_at) FILTER (WHERE status = 'pending'),
        'newest_pending', MAX(created_at) FILTER (WHERE status = 'pending'),
        'avg_processing_time_ms', EXTRACT(EPOCH FROM AVG(processed_at - created_at) FILTER (WHERE status = 'completed')) * 1000,
        'by_action_type', (
            SELECT jsonb_object_agg(action_type, cnt)
            FROM (SELECT action_type, COUNT(*) as cnt FROM outbox.messages WHERE status = 'pending' GROUP BY action_type) s
        ),
        'by_aggregate_type', (
            SELECT jsonb_object_agg(aggregate_type, cnt)
            FROM (SELECT aggregate_type, COUNT(*) as cnt FROM outbox.messages WHERE status = 'pending' GROUP BY aggregate_type) s
        ),
        'generated_at', NOW()
    )
    INTO v_result
    FROM outbox.messages;

    RETURN v_result;
END;
$$;

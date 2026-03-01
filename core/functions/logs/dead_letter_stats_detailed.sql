CREATE OR REPLACE FUNCTION logs.dead_letter_stats_detailed()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN jsonb_build_object(
        'summary', (
            SELECT jsonb_build_object(
                'totalCount', COUNT(*),
                'pendingCount', COUNT(*) FILTER (WHERE status = 'pending'),
                'retryingCount', COUNT(*) FILTER (WHERE status = 'retrying'),
                'resolvedCount', COUNT(*) FILTER (WHERE status = 'resolved'),
                'failedCount', COUNT(*) FILTER (WHERE status = 'failed'),
                'validationFailedCount', COUNT(*) FILTER (WHERE status = 'validation_failed'),
                'maxRetryExceededCount', COUNT(*) FILTER (WHERE status = 'max_retry_exceeded'),
                'ignoredCount', COUNT(*) FILTER (WHERE status = 'ignored'),
                'archivedCount', (SELECT COUNT(*) FROM logs.dead_letter_messages WHERE is_archived = TRUE),
                'todayCount', COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE),
                'lastHourCount', COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '1 hour'),
                'oldestPendingMinutes', EXTRACT(EPOCH FROM (NOW() - MIN(created_at) FILTER (WHERE status = 'pending')))/60,
                'avgRetryCount', ROUND(AVG(retry_count)::NUMERIC, 2)
            ) FROM logs.dead_letter_messages WHERE is_archived = FALSE
        ),
        'byEventType', (
            SELECT COALESCE(jsonb_agg(jsonb_build_object('key', event_type, 'total', cnt, 'pending', pending_cnt) ORDER BY cnt DESC), '[]'::JSONB)
            FROM (SELECT event_type, COUNT(*) cnt, COUNT(*) FILTER (WHERE status = 'pending') pending_cnt
                  FROM logs.dead_letter_messages WHERE is_archived = FALSE GROUP BY event_type LIMIT 20) t
        ),
        'byCluster', (
            SELECT COALESCE(jsonb_agg(jsonb_build_object('key', cluster_id, 'total', cnt, 'pending', pending_cnt)), '[]'::JSONB)
            FROM (SELECT cluster_id, COUNT(*) cnt, COUNT(*) FILTER (WHERE status = 'pending') pending_cnt
                  FROM logs.dead_letter_messages WHERE is_archived = FALSE AND cluster_id IS NOT NULL GROUP BY cluster_id) t
        ),
        'byConsumer', (
            SELECT COALESCE(jsonb_agg(jsonb_build_object('key', consumer_name, 'total', cnt, 'pending', pending_cnt) ORDER BY cnt DESC), '[]'::JSONB)
            FROM (SELECT consumer_name, COUNT(*) cnt, COUNT(*) FILTER (WHERE status = 'pending') pending_cnt
                  FROM logs.dead_letter_messages WHERE is_archived = FALSE AND consumer_name IS NOT NULL GROUP BY consumer_name LIMIT 20) t
        ),
        'byFailureCategory', (
            SELECT COALESCE(jsonb_agg(jsonb_build_object('key', failure_category, 'total', cnt, 'pending', 0) ORDER BY cnt DESC), '[]'::JSONB)
            FROM (SELECT failure_category, COUNT(*) cnt FROM logs.dead_letter_messages
                  WHERE is_archived = FALSE AND failure_category IS NOT NULL GROUP BY failure_category) t
        ),
        'byClient', (
            SELECT COALESCE(jsonb_agg(jsonb_build_object('key', client_id, 'total', cnt, 'pending', pending_cnt) ORDER BY cnt DESC), '[]'::JSONB)
            FROM (SELECT client_id, COUNT(*) cnt, COUNT(*) FILTER (WHERE status = 'pending') pending_cnt
                  FROM logs.dead_letter_messages WHERE is_archived = FALSE AND client_id IS NOT NULL GROUP BY client_id LIMIT 20) t
        ),
        'hourlyTrend', (
            SELECT COALESCE(jsonb_agg(jsonb_build_object('hour', h, 'count', cnt) ORDER BY h), '[]'::JSONB)
            FROM (SELECT DATE_TRUNC('hour', created_at) AS h, COUNT(*) cnt FROM logs.dead_letter_messages
                  WHERE created_at >= NOW() - INTERVAL '24 hours' GROUP BY DATE_TRUNC('hour', created_at)) t
        ),
        'lastUpdated', NOW()
    );
END;
$$;

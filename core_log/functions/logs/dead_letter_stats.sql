DROP FUNCTION IF EXISTS logs.dead_letter_stats();

-- Get dead letter statistics
CREATE OR REPLACE FUNCTION logs.dead_letter_stats()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'totalCount', COUNT(*),
        'pendingCount', COUNT(*) FILTER (WHERE status = 'pending'),
        'retryingCount', COUNT(*) FILTER (WHERE status = 'retrying'),
        'resolvedCount', COUNT(*) FILTER (WHERE status = 'resolved'),
        'failedCount', COUNT(*) FILTER (WHERE status = 'failed'),
        'todayCount', COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE),
        'lastWeekCount', COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'),
        'oldestPending', MIN(created_at) FILTER (WHERE status = 'pending'),
        'lastUpdated', NOW()
    ) INTO v_result
    FROM logs.dead_letter_messages;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION logs.dead_letter_stats IS 'Calculates dead letter message statistics (counts by status, etc.)';

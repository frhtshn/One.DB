DROP FUNCTION IF EXISTS logs.error_stats(BIGINT, INT);

-- Get error statistics
CREATE OR REPLACE FUNCTION logs.error_stats(
    p_client_id BIGINT DEFAULT NULL,
    p_hours INT DEFAULT 24
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
    v_since TIMESTAMPTZ;
BEGIN
    v_since := NOW() - (p_hours || ' hours')::INTERVAL;

    SELECT jsonb_build_object(
        'totalCount', COUNT(*),
        'serverErrorCount', COUNT(*) FILTER (WHERE http_status_code >= 500),
        'clientErrorCount', COUNT(*) FILTER (WHERE http_status_code >= 400 AND http_status_code < 500),
        'retryableCount', COUNT(*) FILTER (WHERE is_retryable = TRUE),
        'topErrorCodes', (
            SELECT COALESCE(jsonb_agg(row_to_json(t)::JSONB), '[]'::JSONB)
            FROM (
                SELECT error_code AS "errorCode", COUNT(*) AS count
                FROM logs.error_logs
                WHERE occurred_at >= v_since
                  AND (p_client_id IS NULL OR client_id = p_client_id)
                GROUP BY error_code
                ORDER BY count DESC
                LIMIT 10
            ) t
        ),
        'errorsByCluster', (
            SELECT COALESCE(jsonb_agg(row_to_json(t)::JSONB), '[]'::JSONB)
            FROM (
                SELECT cluster_name AS "clusterName", COUNT(*) AS count
                FROM logs.error_logs
                WHERE occurred_at >= v_since
                  AND (p_client_id IS NULL OR client_id = p_client_id)
                  AND cluster_name IS NOT NULL
                GROUP BY cluster_name
                ORDER BY count DESC
            ) t
        ),
        'since', v_since,
        'generatedAt', NOW()
    ) INTO v_result
    FROM logs.error_logs
    WHERE occurred_at >= v_since
      AND (p_client_id IS NULL OR client_id = p_client_id);

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION logs.error_stats IS 'Calculates error statistics (counts, top errors, etc.)';

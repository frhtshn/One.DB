DROP FUNCTION IF EXISTS logs.error_list(BIGINT, TEXT, TIMESTAMPTZ, TIMESTAMPTZ, INT);

-- Get recent errors with filtering
CREATE OR REPLACE FUNCTION logs.error_list(
    p_client_id BIGINT DEFAULT NULL,
    p_error_code TEXT DEFAULT NULL,
    p_from_date TIMESTAMPTZ DEFAULT NULL,
    p_to_date TIMESTAMPTZ DEFAULT NULL,
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
                'id', e.id,
                'errorCode', e.error_code,
                'errorMessage', e.error_message,
                'exceptionType', e.exception_type,
                'httpStatusCode', e.http_status_code,
                'isRetryable', e.is_retryable,
                'clientId', e.client_id,
                'userId', e.user_id,
                'correlationId', e.correlation_id,
                'requestPath', e.request_path,
                'requestMethod', e.request_method,
                'resourceType', e.resource_type,
                'resourceKey', e.resource_key,
                'errorMetadata', e.error_metadata,
                'stackTrace', e.stack_trace,
                'clusterName', e.cluster_name,
                'occurredAt', e.occurred_at,
                'createdAt', e.created_at
            )
            ORDER BY e.occurred_at DESC
        ),
        '[]'::JSONB
    ) INTO v_result
    FROM logs.error_logs e
    WHERE (p_client_id IS NULL OR e.client_id = p_client_id)
      AND (p_error_code IS NULL OR e.error_code = p_error_code)
      AND (p_from_date IS NULL OR e.occurred_at >= p_from_date)
      AND (p_to_date IS NULL OR e.occurred_at <= p_to_date)
    LIMIT p_limit;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION logs.error_list IS 'Retrieves filtered application errors as JSONB array';

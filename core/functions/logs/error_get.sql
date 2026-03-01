DROP FUNCTION IF EXISTS logs.error_get(BIGINT);

-- Get error by ID
CREATE OR REPLACE FUNCTION logs.error_get(
    p_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
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
    ) INTO v_result
    FROM logs.error_logs e
    WHERE e.id = p_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.logs.errornotfound';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION logs.error_get IS 'Gets error detail by ID as JSONB';

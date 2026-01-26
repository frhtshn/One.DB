-- ============================================================================
-- ERROR LOG FUNCTIONS
-- ============================================================================

DROP FUNCTION IF EXISTS logs.error_log(TEXT, TEXT, TEXT, INT, BOOLEAN, BIGINT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TIMESTAMPTZ);

-- Log error - returns inserted ID
CREATE OR REPLACE FUNCTION logs.error_log(
    p_error_code TEXT,
    p_error_message TEXT,
    p_exception_type TEXT DEFAULT NULL,
    p_http_status_code INT DEFAULT 500,
    p_is_retryable BOOLEAN DEFAULT FALSE,
    p_tenant_id BIGINT DEFAULT NULL,
    p_user_id TEXT DEFAULT NULL,
    p_correlation_id TEXT DEFAULT NULL,
    p_request_path TEXT DEFAULT NULL,
    p_request_method TEXT DEFAULT NULL,
    p_resource_type TEXT DEFAULT NULL,
    p_resource_key TEXT DEFAULT NULL,
    p_error_metadata TEXT DEFAULT NULL,
    p_stack_trace TEXT DEFAULT NULL,
    p_cluster_name TEXT DEFAULT NULL,
    p_occurred_at TIMESTAMPTZ DEFAULT NOW()
)
RETURNS TABLE(id BIGINT)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id BIGINT;
BEGIN
    INSERT INTO logs.error_logs (
        error_code, error_message, exception_type, http_status_code,
        is_retryable, tenant_id, user_id, correlation_id,
        request_path, request_method, resource_type, resource_key,
        error_metadata, stack_trace, cluster_name, occurred_at
    ) VALUES (
        p_error_code, p_error_message, p_exception_type, p_http_status_code,
        p_is_retryable, p_tenant_id, p_user_id, p_correlation_id,
        p_request_path, p_request_method, p_resource_type, p_resource_key,
        CASE WHEN p_error_metadata IS NOT NULL THEN p_error_metadata::JSONB ELSE NULL END,
        p_stack_trace, p_cluster_name, p_occurred_at
    )
    RETURNING logs.error_logs.id INTO v_id;

    RETURN QUERY SELECT v_id;
END;
$$;

COMMENT ON FUNCTION logs.error_log IS 'Logs an application error, returns ID';

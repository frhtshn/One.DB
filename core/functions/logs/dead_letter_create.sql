DROP FUNCTION IF EXISTS logs.dead_letter_create;

CREATE OR REPLACE FUNCTION logs.dead_letter_create(
    p_event_id VARCHAR(255),
    p_event_type VARCHAR(255),
    p_tenant_id VARCHAR(100) DEFAULT NULL,
    p_payload JSONB DEFAULT NULL,
    p_exception_message TEXT DEFAULT NULL,
    p_exception_stack_trace TEXT DEFAULT NULL,
    p_retry_count INT DEFAULT 0,
    p_status VARCHAR(50) DEFAULT 'pending',
    p_cluster_id VARCHAR(50) DEFAULT NULL,
    p_consumer_name VARCHAR(255) DEFAULT NULL,
    p_original_event_id VARCHAR(255) DEFAULT NULL,
    p_failure_category VARCHAR(100) DEFAULT NULL,
    p_correlation_id VARCHAR(255) DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_id UUID;
BEGIN
    INSERT INTO logs.dead_letter_messages (
        event_id, event_type, tenant_id, payload,
        exception_message, exception_stack_trace, retry_count, status,
        cluster_id, consumer_name,
        original_event_id, failure_category, correlation_id
    ) VALUES (
        p_event_id, p_event_type, p_tenant_id, p_payload,
        p_exception_message, p_exception_stack_trace, p_retry_count, p_status,
        p_cluster_id, p_consumer_name,
        COALESCE(p_original_event_id, p_event_id), p_failure_category, p_correlation_id
    )
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

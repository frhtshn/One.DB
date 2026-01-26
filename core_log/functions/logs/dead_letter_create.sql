-- ============================================================================
-- DEAD LETTER FUNCTIONS
-- ============================================================================

DROP FUNCTION IF EXISTS logs.dead_letter_create(VARCHAR, VARCHAR, VARCHAR, JSONB, TEXT, TEXT, INT, VARCHAR);

-- Save dead letter message - returns UUID
CREATE OR REPLACE FUNCTION logs.dead_letter_create(
    p_event_id VARCHAR(255),
    p_event_type VARCHAR(255),
    p_tenant_id VARCHAR(100) DEFAULT NULL,
    p_payload JSONB DEFAULT NULL,
    p_exception_message TEXT DEFAULT NULL,
    p_exception_stack_trace TEXT DEFAULT NULL,
    p_retry_count INT DEFAULT 0,
    p_status VARCHAR(50) DEFAULT 'pending'
)
RETURNS TABLE(id UUID)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id UUID;
BEGIN
    INSERT INTO logs.dead_letter_messages (
        event_id, event_type, tenant_id, payload,
        exception_message, exception_stack_trace, retry_count, status
    ) VALUES (
        p_event_id, p_event_type, p_tenant_id, p_payload,
        p_exception_message, p_exception_stack_trace, p_retry_count, p_status
    )
    RETURNING logs.dead_letter_messages.id INTO v_id;

    RETURN QUERY SELECT v_id;
END;
$$;

COMMENT ON FUNCTION logs.dead_letter_create IS 'Saves a dead letter message for later retry/analysis';

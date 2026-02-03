-- ================================================================
-- OUTBOX_GET_PENDING - Bekleyen mesajları al (FOR UPDATE SKIP LOCKED)
-- ================================================================

CREATE OR REPLACE FUNCTION outbox.outbox_get_pending(
    p_batch_size INT DEFAULT 100
)
RETURNS TABLE(
    id UUID,
    action_type VARCHAR(50),
    aggregate_type VARCHAR(100),
    aggregate_id VARCHAR(100),
    payload JSONB,
    tenant_id BIGINT,
    correlation_id UUID,
    retry_count INT,
    max_retries INT,
    sequence_number BIGINT,
    created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    WITH pending AS (
        SELECT m.id
        FROM outbox.messages m
        WHERE m.status = 'pending'
           OR (m.status = 'failed' AND m.retry_count < m.max_retries AND m.next_retry_at <= NOW())
        ORDER BY m.sequence_number
        LIMIT p_batch_size
        FOR UPDATE SKIP LOCKED
    )
    UPDATE outbox.messages m
    SET status = 'processing'
    FROM pending p
    WHERE m.id = p.id
    RETURNING
        m.id, m.action_type, m.aggregate_type, m.aggregate_id,
        m.payload, m.tenant_id, m.correlation_id,
        m.retry_count, m.max_retries, m.sequence_number, m.created_at;
END;
$$;

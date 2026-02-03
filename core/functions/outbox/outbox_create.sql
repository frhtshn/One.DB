-- ================================================================
-- OUTBOX_CREATE: Tek mesaj oluşturur
-- ================================================================

DROP FUNCTION IF EXISTS outbox.outbox_create CASCADE;
CREATE OR REPLACE FUNCTION outbox.outbox_create(
    p_action_type VARCHAR(50),
    p_aggregate_type VARCHAR(100),
    p_aggregate_id VARCHAR(100),
    p_payload TEXT,
    p_tenant_id BIGINT DEFAULT NULL,
    p_correlation_id UUID DEFAULT NULL,
    p_max_retries INT DEFAULT 5
)
RETURNS UUID
LANGUAGE plpgsql
AS $$
DECLARE
    v_id UUID;
BEGIN
    INSERT INTO outbox.messages (
        action_type, aggregate_type, aggregate_id, payload,
        tenant_id, correlation_id, max_retries
    )
    VALUES (
        p_action_type, p_aggregate_type, p_aggregate_id, p_payload::JSONB,
        p_tenant_id, COALESCE(p_correlation_id, gen_random_uuid()), p_max_retries
    )
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION outbox.outbox_create IS 'Creates a single outbox message for reliable event delivery using transactional outbox pattern. Returns UUID of created message.';

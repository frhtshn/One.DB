-- ================================================================
-- OUTBOX_CREATE_BATCH - Toplu mesaj oluştur
-- ================================================================

CREATE OR REPLACE FUNCTION outbox.outbox_create_batch(
    p_messages TEXT  -- JSON array string
)
RETURNS TABLE(id UUID, sequence_number BIGINT)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    INSERT INTO outbox.messages (
        action_type, aggregate_type, aggregate_id, payload,
        tenant_id, correlation_id, max_retries
    )
    SELECT
        msg->>'action_type',
        msg->>'aggregate_type',
        msg->>'aggregate_id',
        (msg->>'payload')::JSONB,
        (msg->>'tenant_id')::BIGINT,
        COALESCE((msg->>'correlation_id')::UUID, gen_random_uuid()),
        COALESCE((msg->>'max_retries')::INT, 5)
    FROM jsonb_array_elements(p_messages::JSONB) AS msg
    RETURNING outbox.messages.id, outbox.messages.sequence_number;
END;
$$;

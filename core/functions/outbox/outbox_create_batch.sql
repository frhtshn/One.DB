-- ================================================================
-- OUTBOX_CREATE_BATCH: Toplu mesaj oluşturur
-- ================================================================

DROP FUNCTION IF EXISTS outbox.outbox_create_batch CASCADE;
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
        client_id, correlation_id, max_retries
    )
    SELECT
        msg->>'action_type',
        msg->>'aggregate_type',
        msg->>'aggregate_id',
        (msg->>'payload')::JSONB,
        (msg->>'client_id')::BIGINT,
        COALESCE((msg->>'correlation_id')::UUID, gen_random_uuid()),
        COALESCE((msg->>'max_retries')::INT, 5)
    FROM jsonb_array_elements(p_messages::JSONB) AS msg
    RETURNING outbox.messages.id, outbox.messages.sequence_number;
END;
$$;

COMMENT ON FUNCTION outbox.outbox_create_batch IS 'Creates multiple outbox messages in a single batch operation. Accepts JSON array of messages. Returns TABLE(id UUID, sequence_number BIGINT).';

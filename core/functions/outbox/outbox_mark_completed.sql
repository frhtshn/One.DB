-- ================================================================
-- OUTBOX_MARK_COMPLETED: Tek mesajı tamamlandı olarak işaretler
-- ================================================================

DROP FUNCTION IF EXISTS outbox.outbox_mark_completed CASCADE;
CREATE OR REPLACE FUNCTION outbox.outbox_mark_completed(
    p_id UUID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE outbox.messages
    SET status = 'completed',
        processed_at = NOW()
    WHERE id = p_id AND status = 'processing';

    RETURN FOUND;
END;
$$;

COMMENT ON FUNCTION outbox.outbox_mark_completed IS 'Marks a single message as successfully completed. Returns BOOLEAN.';

-- ================================================================
-- OUTBOX_MARK_COMPLETED_BATCH: Birden fazla mesajı tamamlandı olarak işaretler
-- ================================================================

DROP FUNCTION IF EXISTS outbox.outbox_mark_completed_batch CASCADE;
CREATE OR REPLACE FUNCTION outbox.outbox_mark_completed_batch(
    p_ids UUID[]
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INT;
BEGIN
    UPDATE outbox.messages
    SET status = 'completed',
        processed_at = NOW()
    WHERE id = ANY(p_ids) AND status = 'processing';

    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN v_count;
END;
$$;

COMMENT ON FUNCTION outbox.outbox_mark_completed_batch IS 'Marks multiple messages as successfully completed. Returns count of updated rows.';

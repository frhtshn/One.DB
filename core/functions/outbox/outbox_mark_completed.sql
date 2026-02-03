-- ================================================================
-- OUTBOX_MARK_COMPLETED - Mesajı tamamlandı olarak işaretle
-- ================================================================

-- Tek mesaj için
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

-- Batch için (overload)
CREATE OR REPLACE FUNCTION outbox.outbox_mark_completed(
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

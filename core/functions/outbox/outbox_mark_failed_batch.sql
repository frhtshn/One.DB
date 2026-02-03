-- ================================================================
-- OUTBOX_MARK_FAILED_BATCH: Birden fazla mesajı başarısız olarak işaretler
-- ================================================================

DROP FUNCTION IF EXISTS outbox.outbox_mark_failed_batch CASCADE;
CREATE OR REPLACE FUNCTION outbox.outbox_mark_failed_batch(
    p_ids UUID[],
    p_error TEXT
)
RETURNS INT
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INT := 0;
    v_id UUID;
BEGIN
    FOREACH v_id IN ARRAY p_ids LOOP
        IF outbox.outbox_mark_failed(v_id, p_error) THEN
            v_count := v_count + 1;
        END IF;
    END LOOP;

    RETURN v_count;
END;
$$;

COMMENT ON FUNCTION outbox.outbox_mark_failed_batch IS 'Marks multiple messages as failed with the same error. Returns count of updated rows.';

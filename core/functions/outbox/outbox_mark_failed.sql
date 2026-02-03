-- ================================================================
-- OUTBOX_MARK_FAILED: Mesajı başarısız olarak işaretler
-- ================================================================

DROP FUNCTION IF EXISTS outbox.outbox_mark_failed CASCADE;
CREATE OR REPLACE FUNCTION outbox.outbox_mark_failed(
    p_id UUID,
    p_error TEXT
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_retry_count INT;
    v_max_retries INT;
    v_next_retry TIMESTAMPTZ;
BEGIN
    SELECT retry_count, max_retries
    INTO v_retry_count, v_max_retries
    FROM outbox.messages
    WHERE id = p_id;

    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;

    -- Exponential backoff: 2^retry_count saniye (max 5 dakika)
    v_next_retry := NOW() + LEAST(POWER(2, v_retry_count + 1), 300) * INTERVAL '1 second';

    UPDATE outbox.messages
    SET status = CASE
            WHEN v_retry_count + 1 >= v_max_retries THEN 'failed'
            ELSE 'failed'
        END,
        retry_count = v_retry_count + 1,
        next_retry_at = CASE
            WHEN v_retry_count + 1 < v_max_retries THEN v_next_retry
            ELSE NULL
        END,
        last_error = p_error,
        processed_at = NOW()
    WHERE id = p_id;

    RETURN TRUE;
END;
$$;

COMMENT ON FUNCTION outbox.outbox_mark_failed IS 'Marks a message as failed and schedules retry with exponential backoff (max 5 min). Returns BOOLEAN.';

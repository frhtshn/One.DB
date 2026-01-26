DROP FUNCTION IF EXISTS logs.dead_letter_retry(UUID);

-- Increment retry count and set status to retrying
CREATE OR REPLACE FUNCTION logs.dead_letter_retry(
    p_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_affected INT;
BEGIN
    UPDATE logs.dead_letter_messages
    SET
        status = 'retrying',
        retry_count = retry_count + 1,
        updated_at = NOW()
    WHERE id = p_id
      AND status IN ('pending', 'retrying');

    GET DIAGNOSTICS v_affected = ROW_COUNT;

    IF v_affected = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.logs.deadletternotfound';
    END IF;
END;
$$;

COMMENT ON FUNCTION logs.dead_letter_retry IS 'Increments retry count and sets status to RETRYING for a message';

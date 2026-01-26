DROP FUNCTION IF EXISTS logs.dead_letter_update_status(UUID, VARCHAR, VARCHAR, TEXT);

-- Update dead letter status
CREATE OR REPLACE FUNCTION logs.dead_letter_update_status(
    p_id UUID,
    p_status VARCHAR(50),
    p_resolved_by VARCHAR(255) DEFAULT NULL,
    p_resolution_notes TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_affected INT;
BEGIN
    UPDATE logs.dead_letter_messages
    SET
        status = p_status,
        updated_at = NOW(),
        resolved_at = CASE WHEN p_status IN ('resolved', 'failed') THEN NOW() ELSE resolved_at END,
        resolved_by = COALESCE(p_resolved_by, resolved_by),
        resolution_notes = COALESCE(p_resolution_notes, resolution_notes)
    WHERE id = p_id;

    GET DIAGNOSTICS v_affected = ROW_COUNT;

    IF v_affected = 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.logs.deadletternotfound';
    END IF;
END;
$$;

COMMENT ON FUNCTION logs.dead_letter_update_status IS 'Updates status and resolution details of a dead letter message';

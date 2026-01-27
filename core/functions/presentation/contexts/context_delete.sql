-- ================================================================
-- CONTEXT_DELETE: Context Silme
-- Context'i kalıcı olarak siler (Hard Delete).
-- ================================================================

DROP FUNCTION IF EXISTS presentation.context_delete CASCADE;

CREATE OR REPLACE FUNCTION presentation.context_delete(
    p_id BIGINT
) RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Check existence and active status
    IF NOT EXISTS (SELECT 1 FROM presentation.contexts WHERE id = p_id AND is_active) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.context.not-found';
    END IF;

    -- Soft delete: set is_active to FALSE
    UPDATE presentation.contexts
    SET is_active = FALSE,
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION presentation.context_delete IS 'Deletes a context (hard delete). Returns VOID.';

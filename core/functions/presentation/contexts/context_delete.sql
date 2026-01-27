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
    -- Check existence
    IF NOT EXISTS (SELECT 1 FROM presentation.contexts WHERE id = p_id) THEN
        RAISE EXCEPTION 'error.context.not-found';
    END IF;

    -- Soft delete: remove context (hard delete, since no is_active field)
    DELETE FROM presentation.contexts WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION presentation.context_delete IS 'Deletes a context (hard delete). Returns VOID.';

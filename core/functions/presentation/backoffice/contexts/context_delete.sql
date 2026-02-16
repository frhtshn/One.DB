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
DECLARE
    v_is_active BOOLEAN;
BEGIN
    -- Var mı kontrol et
    SELECT is_active INTO v_is_active FROM presentation.contexts WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.context.not-found';
    END IF;

    IF v_is_active = FALSE THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.context.delete.already-deleted';
    END IF;

    -- Soft delete: set is_active to FALSE
    UPDATE presentation.contexts
    SET is_active = FALSE,
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION presentation.context_delete IS 'Deletes a context (hard delete). Returns VOID.';

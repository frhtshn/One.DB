-- ================================================================
-- TAB_DELETE: Sekme Silme (Soft Delete)
-- Sekmeyi pasif duruma getirir.
-- ================================================================

DROP FUNCTION IF EXISTS presentation.tab_delete CASCADE;

CREATE OR REPLACE FUNCTION presentation.tab_delete(
    p_tab_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_is_active BOOLEAN;
BEGIN
    -- Sekme var mı kontrol et
    SELECT is_active INTO v_is_active FROM presentation.tabs WHERE id = p_tab_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tab.not-found';
    END IF;

    IF v_is_active = FALSE THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.tab.delete.already-deleted';
    END IF;

    -- Soft delete işlemi
    UPDATE presentation.tabs
    SET is_active = FALSE,
        updated_at = NOW()
    WHERE id = p_tab_id;
END;
$$;

COMMENT ON FUNCTION presentation.tab_delete IS 'Soft deletes a tab by setting is_active to FALSE and updating updated_at.';

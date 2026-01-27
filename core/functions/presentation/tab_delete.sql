-- ================================================================
-- TAB_DELETE: Sekme sil (soft delete)
-- ================================================================

DROP FUNCTION IF EXISTS presentation.tab_delete CASCADE;
CREATE OR REPLACE FUNCTION presentation.tab_delete(
    p_tab_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Sekme var mı kontrol et
    IF NOT EXISTS (SELECT 1 FROM presentation.tabs WHERE id = p_tab_id AND is_active) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tab.not-found';
    END IF;

    -- Soft delete işlemi
    UPDATE presentation.tabs
    SET is_active = FALSE,
        updated_at = NOW()
    WHERE id = p_tab_id;
END;
$$;

COMMENT ON FUNCTION presentation.tab_delete IS 'Soft deletes a tab by setting is_active to FALSE and updating updated_at.';

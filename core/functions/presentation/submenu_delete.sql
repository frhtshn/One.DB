-- ================================================================
-- SUBMENU_DELETE: Alt menü sil (soft delete)
-- ================================================================

DROP FUNCTION IF EXISTS presentation.submenu_delete CASCADE;
CREATE OR REPLACE FUNCTION presentation.submenu_delete(
    p_submenu_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Alt menü var mı kontrol et
    IF NOT EXISTS (SELECT 1 FROM presentation.submenus WHERE id = p_submenu_id AND is_active) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.submenu.not-found';
    END IF;

    -- Soft delete işlemi
    UPDATE presentation.submenus
    SET is_active = FALSE,
        updated_at = NOW()
    WHERE id = p_submenu_id;
END;
$$;

COMMENT ON FUNCTION presentation.submenu_delete IS 'Soft deletes a submenu by setting is_active to FALSE and updating updated_at.';

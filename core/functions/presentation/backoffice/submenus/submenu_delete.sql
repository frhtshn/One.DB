-- ================================================================
-- SUBMENU_DELETE: Alt Menü Silme (Soft Delete)
-- Alt menüyü pasif duruma getirir.
-- ================================================================

DROP FUNCTION IF EXISTS presentation.submenu_delete CASCADE;

CREATE OR REPLACE FUNCTION presentation.submenu_delete(
    p_submenu_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_is_active BOOLEAN;
BEGIN
    -- Alt menü var mı kontrol et
    SELECT is_active INTO v_is_active FROM presentation.submenus WHERE id = p_submenu_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.submenu.not-found';
    END IF;

    IF v_is_active = FALSE THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.submenu.delete.already-deleted';
    END IF;

    -- Soft delete işlemi
    UPDATE presentation.submenus
    SET is_active = FALSE,
        updated_at = NOW()
    WHERE id = p_submenu_id;
END;
$$;

COMMENT ON FUNCTION presentation.submenu_delete IS 'Soft deletes a submenu by setting is_active to FALSE and updating updated_at.';

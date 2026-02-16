-- ================================================================
-- MENU_DELETE: Menü Silme (Soft Delete)
-- Menüyü pasif duruma getirir.
-- ================================================================

DROP FUNCTION IF EXISTS presentation.menu_delete CASCADE;

CREATE OR REPLACE FUNCTION presentation.menu_delete(
    p_menu_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_is_active BOOLEAN;
BEGIN
    -- Menü var mı kontrol et
    SELECT is_active INTO v_is_active FROM presentation.menus WHERE id = p_menu_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.menu.not-found';
    END IF;

    IF v_is_active = FALSE THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.menu.delete.already-deleted';
    END IF;

    -- Soft delete işlemi
    UPDATE presentation.menus
    SET is_active = FALSE,
        deleted_at = NOW()
    WHERE id = p_menu_id;
END;
$$;

COMMENT ON FUNCTION presentation.menu_delete IS 'Soft deletes a menu by setting is_active to FALSE and updating deleted_at.';

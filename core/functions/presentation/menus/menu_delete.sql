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
BEGIN
    -- Menü var mı kontrol et
    IF NOT EXISTS (SELECT 1 FROM presentation.menus WHERE id = p_menu_id AND is_active) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.menu.not-found';
    END IF;

    -- Soft delete işlemi
    UPDATE presentation.menus
    SET is_active = FALSE,
        deleted_at = NOW()
    WHERE id = p_menu_id;
END;
$$;

COMMENT ON FUNCTION presentation.menu_delete IS 'Soft deletes a menu by setting is_active to FALSE and updating deleted_at.';

-- ================================================================
-- MENU_GROUP_DELETE: Menü grubu sil (soft delete)
-- is_active = FALSE olarak işaretler
-- ================================================================

DROP FUNCTION IF EXISTS presentation.menu_group_delete CASCADE;

CREATE OR REPLACE FUNCTION presentation.menu_group_delete(
    p_menu_group_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_is_active BOOLEAN;
BEGIN
    -- Menü grubu var mı kontrol et
    SELECT is_active
    INTO v_is_active
    FROM presentation.menu_groups
    WHERE id = p_menu_group_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.menu-group.not-found';
    END IF;

    -- Zaten silinmiş mi kontrol et
    IF v_is_active = FALSE THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.menu-group.delete.already-deleted';
    END IF;

    -- Soft delete: is_active = FALSE
    UPDATE presentation.menu_groups
    SET is_active = FALSE,
        updated_at = NOW()
    WHERE id = p_menu_group_id;
END;
$$;

COMMENT ON FUNCTION presentation.menu_group_delete IS 'Soft deletes a menu group by setting is_active to FALSE';

-- ================================================================
-- MENU_UPDATE: Menü Güncelleme
-- NULL gelen alanlar güncellenmez (Partial Update).
-- ================================================================

DROP FUNCTION IF EXISTS presentation.menu_update CASCADE;

CREATE OR REPLACE FUNCTION presentation.menu_update(
    p_menu_id BIGINT,
    p_menu_group_id BIGINT DEFAULT NULL,
    p_title_localization_key TEXT DEFAULT NULL,
    p_icon TEXT DEFAULT NULL,
    p_order_index INT DEFAULT NULL,
    p_required_permission TEXT DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Menü var mı kontrol et
    IF NOT EXISTS (SELECT 1 FROM presentation.menus WHERE id = p_menu_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.menu.not-found';
    END IF;

    -- Güncelleme (NULL olanlar mevcut değeri korur)
    UPDATE presentation.menus
    SET menu_group_id = COALESCE(p_menu_group_id, menu_group_id),
        title_localization_key = COALESCE(TRIM(p_title_localization_key), title_localization_key),
        icon = COALESCE(TRIM(p_icon), icon),
        order_index = COALESCE(p_order_index, order_index),
        required_permission = CASE
            WHEN p_required_permission IS NULL THEN required_permission
            WHEN TRIM(p_required_permission) = '' THEN NULL
            ELSE TRIM(p_required_permission)
        END,
        is_active = COALESCE(p_is_active, is_active),
        updated_at = NOW()
    WHERE id = p_menu_id;
END;
$$;

COMMENT ON FUNCTION presentation.menu_update IS 'Updates menu with partial update support. NULL values keep existing data.';

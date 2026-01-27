-- ================================================================
-- SUBMENU_UPDATE: Alt Menü Güncelleme
-- NULL gelen alanlar güncellenmez (Partial Update).
-- ================================================================

DROP FUNCTION IF EXISTS presentation.submenu_update CASCADE;

CREATE OR REPLACE FUNCTION presentation.submenu_update(
    p_submenu_id BIGINT,
    p_menu_id BIGINT DEFAULT NULL,
    p_title_localization_key TEXT DEFAULT NULL,
    p_route TEXT DEFAULT NULL,
    p_order_index INT DEFAULT NULL,
    p_required_permission TEXT DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Alt menü var mı kontrol et
    IF NOT EXISTS (SELECT 1 FROM presentation.submenus WHERE id = p_submenu_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.submenu.not-found';
    END IF;

    -- Güncelleme (NULL olanlar mevcut değeri korur)
    UPDATE presentation.submenus
    SET menu_id = COALESCE(p_menu_id, menu_id),
        title_localization_key = COALESCE(TRIM(p_title_localization_key), title_localization_key),
        route = COALESCE(TRIM(p_route), route),
        order_index = COALESCE(p_order_index, order_index),
        required_permission = CASE
            WHEN p_required_permission IS NULL THEN required_permission
            WHEN TRIM(p_required_permission) = '' THEN NULL
            ELSE TRIM(p_required_permission)
        END,
        is_active = COALESCE(p_is_active, is_active),
        updated_at = NOW()
    WHERE id = p_submenu_id;
END;
$$;

COMMENT ON FUNCTION presentation.submenu_update IS 'Updates submenu with partial update support. NULL values keep existing data.';

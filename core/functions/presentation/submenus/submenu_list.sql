-- ================================================================
-- SUBMENU_LIST: Alt Menü Listesi
-- Belirli bir menüye ait aktif alt menüleri listeler.
-- ================================================================

DROP FUNCTION IF EXISTS presentation.submenu_list CASCADE;

CREATE OR REPLACE FUNCTION presentation.submenu_list(
    p_menu_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_items JSONB;
    v_total_count INT;
BEGIN
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', s.id,
        'code', s.code,
        'title', lk.localization_key,
        'route', s.route,
        'order', s.order_index,
        'permission', s.required_permission,
        'menuId', s.menu_id,
        'createdAt', s.created_at,
        'updatedAt', s.updated_at,
        'isActive', s.is_active,
        'pages', '[]'::jsonb
    )), '[]'::jsonb)
    INTO v_items
    FROM presentation.submenus s
    LEFT JOIN catalog.localization_keys lk ON lk.localization_key = s.title_localization_key
    WHERE s.menu_id = p_menu_id
      AND s.is_active;

    SELECT COUNT(1)
    INTO v_total_count
    FROM presentation.submenus s
    WHERE s.menu_id = p_menu_id
      AND s.is_active;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total_count
    );
END;
$$;

COMMENT ON FUNCTION presentation.submenu_list IS 'Lists submenus for a given menu, returns items and totalCount.';

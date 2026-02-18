-- ================================================================
-- PAGE_LIST: Sayfa Listesi (Admin)
-- Filtre verilirse ilgili menu/submenu sayfalarini,
-- filtre verilmezse sadece standalone sayfalari doner.
-- ================================================================

DROP FUNCTION IF EXISTS presentation.page_list CASCADE;

CREATE OR REPLACE FUNCTION presentation.page_list(
    p_menu_id BIGINT DEFAULT NULL,
    p_submenu_id BIGINT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_items JSONB;
    v_total_count INT;
BEGIN
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', p.id,
        'code', p.code,
        'route', p.route,
        'title', COALESCE(lk.localization_key, p.title_localization_key),
        'permission', p.required_permission,
        'menuId', p.menu_id,
        'submenuId', p.submenu_id,
        'isActive', p.is_active,
        'createdAt', p.created_at,
        'updatedAt', p.updated_at,
        'tabs', '[]'::jsonb,
        'contexts', '[]'::jsonb
    )), '[]'::jsonb)
    INTO v_items
    FROM presentation.pages p
    LEFT JOIN catalog.localization_keys lk ON lk.localization_key = p.title_localization_key
    WHERE (p_menu_id IS NOT NULL AND p.menu_id = p_menu_id)
       OR (p_submenu_id IS NOT NULL AND p.submenu_id = p_submenu_id)
       OR (p_menu_id IS NULL AND p_submenu_id IS NULL
           AND p.menu_id IS NULL AND p.submenu_id IS NULL);

    SELECT COUNT(1)
    INTO v_total_count
    FROM presentation.pages p
    WHERE (p_menu_id IS NOT NULL AND p.menu_id = p_menu_id)
       OR (p_submenu_id IS NOT NULL AND p.submenu_id = p_submenu_id)
       OR (p_menu_id IS NULL AND p_submenu_id IS NULL
           AND p.menu_id IS NULL AND p.submenu_id IS NULL);

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total_count
    );
END;
$$;

COMMENT ON FUNCTION presentation.page_list IS 'Lists pages by menu/submenu filter. No filter returns standalone pages only.';

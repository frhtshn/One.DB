-- ================================================================
-- PAGE_LIST: Sayfa Listesi
-- Menü veya alt menüye göre aktif sayfaları listeler.
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
        'title', lk.localization_key,
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
    WHERE (p_menu_id IS NULL OR p.menu_id = p_menu_id)
      AND (p_submenu_id IS NULL OR p.submenu_id = p_submenu_id)
      AND p.is_active;

    SELECT COUNT(1)
    INTO v_total_count
    FROM presentation.pages p
    WHERE (p_menu_id IS NULL OR p.menu_id = p_menu_id)
      AND (p_submenu_id IS NULL OR p.submenu_id = p_submenu_id)
      AND p.is_active;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total_count
    );
END;
$$;

COMMENT ON FUNCTION presentation.page_list IS 'Lists pages for a given menu or submenu, returns items and totalCount.';

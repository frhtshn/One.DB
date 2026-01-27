-- ================================================================
-- MENU_LIST: Menü Listesi
-- Belirli bir gruba ait aktif menüleri listeler.
-- ================================================================

DROP FUNCTION IF EXISTS presentation.menu_list(BIGINT) CASCADE;

CREATE OR REPLACE FUNCTION presentation.menu_list(
    p_menu_group_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_items JSONB;
    v_total_count INT;
BEGIN
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', m.id,
        'code', m.code,
        'title', lk.key, -- localization key
        'icon', m.icon,
        'order', m.order_index,
        'permission', m.required_permission,
        'menuGroupId', m.menu_group_id,
        'createdAt', m.created_at,
        'updatedAt', m.updated_at,
        'isActive', m.is_active,
        'submenuCount', (
            SELECT COUNT(1) FROM presentation.submenus s WHERE s.menu_id = m.id AND s.is_active
        ),
        'submenus', '[]'::jsonb, -- to be filled by frontend or join if needed
        'pages', '[]'::jsonb,    -- to be filled by frontend or join if needed
        'isSystem', m.is_system,
        'description', m.description,
        'createdBy', m.created_by,
        'updatedBy', m.updated_by,
        'deletedAt', m.deleted_at,
        'deletedBy', m.deleted_by
    )), '[]'::jsonb)
    INTO v_items
    FROM presentation.menus m
    LEFT JOIN catalog.localization_keys lk ON lk.key = m.title_localization_key
    WHERE m.menu_group_id = p_menu_group_id
      AND m.is_active;

    SELECT COUNT(1)
    INTO v_total_count
    FROM presentation.menus m
    WHERE m.menu_group_id = p_menu_group_id
      AND m.is_active;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total_count
    );
END;
$$;

COMMENT ON FUNCTION presentation.menu_list IS 'Lists menus for a given group, returns items and totalCount';

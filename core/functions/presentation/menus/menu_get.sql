-- ================================================================
-- MENU_GET: Menü Detayı
-- Menü grubunu, alt menüleri ve audit bilgilerini içerir.
-- ================================================================

DROP FUNCTION IF EXISTS presentation.menu_get CASCADE;

CREATE OR REPLACE FUNCTION presentation.menu_get(
    p_menu_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_menu JSONB;
BEGIN
    SELECT jsonb_build_object(
        'id', m.id,
        'code', m.code,
        'title', lk.localization_key, -- localization key
        'icon', m.icon,
        'order', m.order_index,
        'permission', m.required_permission,
        'permissionDescription', perm.description,
        'menuGroupId', m.menu_group_id,
        'menuGroup', jsonb_build_object(
            'id', mg.id,
            'code', mg.code,
            'title', mg_lk.localization_key,
            'order', mg.order_index,
            'permission', mg.required_permission,
            'isActive', mg.is_active
        ),
        'createdAt', m.created_at,
        'updatedAt', m.updated_at,
        'deletedAt', m.deleted_at,
        'isActive', m.is_active,
        'description', m.description,
        'createdBy', cu.username,
        'updatedBy', uu.username,
        'deletedBy', du.username,
        'submenuCount', (
            SELECT COUNT(1) FROM presentation.submenus s WHERE s.menu_id = m.id AND s.is_active
        ),
        'submenus', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'id', s.id,
                'code', s.code,
                'title', slk.localization_key,
                'order', s.order_index,
                'isActive', s.is_active
            ))
            FROM presentation.submenus s
            LEFT JOIN catalog.localization_keys slk ON slk.localization_key = s.title_localization_key
            WHERE s.menu_id = m.id AND s.is_active
        ), '[]'::jsonb),
        'pages', COALESCE((
            SELECT jsonb_agg(jsonb_build_object(
                'id', p.id,
                'code', p.code,
                'title', plk.localization_key,
                'order', p.order_index,
                'isActive', p.is_active
            ))
            FROM presentation.pages p
            LEFT JOIN catalog.localization_keys plk ON plk.localization_key = p.title_localization_key
            WHERE p.menu_id = m.id AND p.is_active
        ), '[]'::jsonb)
    )
    INTO v_menu
    FROM presentation.menus m
    LEFT JOIN catalog.localization_keys lk ON lk.localization_key = m.title_localization_key
    LEFT JOIN presentation.menu_groups mg ON mg.id = m.menu_group_id
    LEFT JOIN catalog.localization_keys mg_lk ON mg_lk.localization_key = mg.title_localization_key
    LEFT JOIN core.users cu ON cu.id = m.created_by
    LEFT JOIN core.users uu ON uu.id = m.updated_by
    LEFT JOIN core.users du ON du.id = m.deleted_by
    LEFT JOIN core.permissions perm ON perm.code = m.required_permission
    WHERE m.id = p_menu_id
      AND m.is_active;

    IF v_menu IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.menu.not-found';
    END IF;

    RETURN v_menu;
END;
$$;

COMMENT ON FUNCTION presentation.menu_get IS 'Returns details of a menu including group, submenus, pages, and audit info';

-- ================================================================
-- MENU_GROUP_LIST: Menü Grubu Listesi
-- Tüm grupları sıralı olarak döner.
-- ================================================================

DROP FUNCTION IF EXISTS presentation.menu_group_list();

CREATE OR REPLACE FUNCTION presentation.menu_group_list()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_count BIGINT;
    v_items JSONB;
BEGIN
    -- Total count
    SELECT COUNT(*)
    INTO v_total_count
    FROM presentation.menu_groups;

    -- Items listesi
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', mg.id,
            'code', mg.code,
            'title', mg.title_localization_key,
            'order', mg.order_index,
            'permission', mg.required_permission,
            'isActive', mg.is_active,
            'createdAt', mg.created_at,
            'updatedAt', mg.updated_at,
            'menuCount', COALESCE((
                SELECT COUNT(*)
                FROM presentation.menus m
                WHERE m.menu_group_id = mg.id
            ), 0)
        ) ORDER BY mg.order_index
    ), '[]'::jsonb)
    INTO v_items
    FROM presentation.menu_groups mg;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total_count
    );
END;
$$;

COMMENT ON FUNCTION presentation.menu_group_list IS 'Returns all menu groups ordered by order_index. Includes menu count per group.';

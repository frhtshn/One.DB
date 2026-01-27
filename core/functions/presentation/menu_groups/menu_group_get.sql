-- ================================================================
-- MENU_GROUP_GET: Menü Grubu Detayı
-- Menü sayısını da içeren menü grubu detayını döner.
-- ================================================================

DROP FUNCTION IF EXISTS presentation.menu_group_get(BIGINT);

CREATE OR REPLACE FUNCTION presentation.menu_group_get(
    p_menu_group_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
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
    )
    INTO v_result
    FROM presentation.menu_groups mg
    WHERE mg.id = p_menu_group_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.menu-group.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION presentation.menu_group_get IS 'Returns single menu group details by ID';

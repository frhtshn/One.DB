-- ================================================================
-- MENU_STRUCTURE: Presentation Yapısını Getir
-- Tüm menü yapısını (Groups > Menus > Submenus > Pages > Tabs/Contexts)
-- JSON formatında ve versiyon hash bilgisi ile döner.
-- ================================================================

DROP FUNCTION IF EXISTS presentation.menu_structure();

CREATE OR REPLACE FUNCTION presentation.menu_structure()
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
    v_version TEXT;
BEGIN
    -- Version hash hesapla (tum updated_at degerlerinden)
    -- Herhangi bir tabloda degisiklik olursa version degisir
    SELECT MD5(STRING_AGG(updated_at::TEXT, ',' ORDER BY tbl, id))
    INTO v_version
    FROM (
        SELECT 'menu_groups' AS tbl, id, updated_at FROM presentation.menu_groups WHERE is_active = true
        UNION ALL
        SELECT 'menus', id, updated_at FROM presentation.menus WHERE is_active = true
        UNION ALL
        SELECT 'submenus', id, updated_at FROM presentation.submenus WHERE is_active = true
        UNION ALL
        SELECT 'pages', id, updated_at FROM presentation.pages WHERE is_active = true
        UNION ALL
        SELECT 'tabs', id, updated_at FROM presentation.tabs WHERE is_active = true
        UNION ALL
        SELECT 'contexts', id, updated_at FROM presentation.contexts
    ) AS all_items;

    -- Ana yapiyi olustur: menuGroups > menus > submenus > pages > tabs/contexts
    SELECT jsonb_build_object(
        'version', COALESCE(v_version, 'initial'),
        'generatedAt', NOW(),
        'menuGroups', (
            SELECT COALESCE(jsonb_agg(
                jsonb_build_object(
                    'id', mg.id,
                    'code', mg.code,
                    'title', mg.title_localization_key,
                    'order', mg.order_index,
                    'menus', (
                        SELECT COALESCE(jsonb_agg(
                            jsonb_build_object(
                                'id', m.id,
                                'code', m.code,
                                'title', m.title_localization_key,
                                'icon', m.icon,
                                'order', m.order_index,
                                'permission', m.required_permission,
                                'submenus', (
                                    -- Submenu'ler ve altindaki sayfalar
                                    SELECT COALESCE(jsonb_agg(
                                        jsonb_build_object(
                                            'id', sm.id,
                                            'code', sm.code,
                                            'title', sm.title_localization_key,
                                            'route', sm.route,
                                            'order', sm.order_index,
                                            'permission', sm.required_permission,
                                            'pages', (
                                                -- Submenu'ye bagli sayfalar
                                                SELECT COALESCE(jsonb_agg(
                                                    presentation.build_page_json(p.id)
                                                    ORDER BY p.id
                                                ), '[]'::JSONB)
                                                FROM presentation.pages p
                                                WHERE p.submenu_id = sm.id AND p.is_active = true
                                            )
                                        )
                                        ORDER BY sm.order_index
                                    ), '[]'::JSONB)
                                    FROM presentation.submenus sm
                                    WHERE sm.menu_id = m.id AND sm.is_active = true
                                ),
                                'pages', (
                                    -- Direkt menu'ye bagli sayfalar (submenu olmadan)
                                    SELECT COALESCE(jsonb_agg(
                                        presentation.build_page_json(p.id)
                                        ORDER BY p.id
                                    ), '[]'::JSONB)
                                    FROM presentation.pages p
                                    WHERE p.menu_id = m.id AND p.is_active = true
                                )
                            )
                            ORDER BY m.order_index
                        ), '[]'::JSONB)
                        FROM presentation.menus m
                        WHERE m.menu_group_id = mg.id AND m.is_active = true
                    )
                )
                ORDER BY mg.order_index
            ), '[]'::JSONB)
            FROM presentation.menu_groups mg
            WHERE mg.is_active = true
        )
    )
    INTO v_result;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION presentation.menu_structure() IS 'Returns entire presentation structure as nested JSON. Uses MD5 version hash for cache invalidation.';

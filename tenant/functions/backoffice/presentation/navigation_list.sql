-- ================================================================
-- NAVIGATION_LIST: Menü listesi (location bazlı, hiyerarşik tree)
-- BO için tüm öğeler (visible + hidden) döner
-- Hiyerarşik yapı: parent → children iç içe
-- ================================================================

DROP FUNCTION IF EXISTS presentation.navigation_list(VARCHAR);

CREATE OR REPLACE FUNCTION presentation.navigation_list(
    p_menu_location     VARCHAR(50) DEFAULT NULL    -- NULL = tüm lokasyonlar
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    -- Recursive CTE ile hiyerarşik ağaç
    WITH RECURSIVE nav_tree AS (
        -- Root öğeler (parent_id IS NULL)
        SELECT
            n.id, n.template_item_id, n.menu_location,
            n.translation_key, n.custom_label,
            n.icon, n.badge_text, n.badge_color,
            n.target_type, n.target_url, n.target_action, n.open_in_new_tab,
            n.parent_id, n.display_order,
            n.is_visible, n.requires_auth, n.requires_guest, n.required_roles,
            n.device_visibility, n.is_locked, n.is_readonly, n.custom_css_class,
            0 AS depth
        FROM presentation.navigation n
        WHERE n.parent_id IS NULL
          AND (p_menu_location IS NULL OR n.menu_location = p_menu_location)

        UNION ALL

        -- Alt öğeler
        SELECT
            c.id, c.template_item_id, c.menu_location,
            c.translation_key, c.custom_label,
            c.icon, c.badge_text, c.badge_color,
            c.target_type, c.target_url, c.target_action, c.open_in_new_tab,
            c.parent_id, c.display_order,
            c.is_visible, c.requires_auth, c.requires_guest, c.required_roles,
            c.device_visibility, c.is_locked, c.is_readonly, c.custom_css_class,
            t.depth + 1
        FROM presentation.navigation c
        INNER JOIN nav_tree t ON c.parent_id = t.id
    ),
    -- Yaprak → kök sırasıyla children oluştur
    leaf_first AS (
        SELECT
            nt.*,
            COALESCE(
                (SELECT jsonb_agg(sub.item ORDER BY sub.display_order)
                 FROM (
                     SELECT jsonb_build_object(
                         'id', c.id,
                         'templateItemId', c.template_item_id,
                         'menuLocation', c.menu_location,
                         'translationKey', c.translation_key,
                         'customLabel', c.custom_label,
                         'icon', c.icon,
                         'badgeText', c.badge_text,
                         'badgeColor', c.badge_color,
                         'targetType', c.target_type,
                         'targetUrl', c.target_url,
                         'targetAction', c.target_action,
                         'openInNewTab', c.open_in_new_tab,
                         'displayOrder', c.display_order,
                         'isVisible', c.is_visible,
                         'requiresAuth', c.requires_auth,
                         'requiresGuest', c.requires_guest,
                         'deviceVisibility', c.device_visibility,
                         'isLocked', c.is_locked,
                         'isReadonly', c.is_readonly,
                         'customCssClass', c.custom_css_class
                     ) AS item,
                     c.display_order
                     FROM nav_tree c
                     WHERE c.parent_id = nt.id
                 ) sub
                ),
                '[]'::JSONB
            ) AS children
        FROM nav_tree nt
        WHERE nt.parent_id IS NULL
    )
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', lf.id,
        'templateItemId', lf.template_item_id,
        'menuLocation', lf.menu_location,
        'translationKey', lf.translation_key,
        'customLabel', lf.custom_label,
        'icon', lf.icon,
        'badgeText', lf.badge_text,
        'badgeColor', lf.badge_color,
        'targetType', lf.target_type,
        'targetUrl', lf.target_url,
        'targetAction', lf.target_action,
        'openInNewTab', lf.open_in_new_tab,
        'displayOrder', lf.display_order,
        'isVisible', lf.is_visible,
        'requiresAuth', lf.requires_auth,
        'requiresGuest', lf.requires_guest,
        'deviceVisibility', lf.device_visibility,
        'isLocked', lf.is_locked,
        'isReadonly', lf.is_readonly,
        'customCssClass', lf.custom_css_class,
        'children', lf.children
    ) ORDER BY lf.display_order), '[]'::JSONB)
    INTO v_result
    FROM leaf_first lf;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION presentation.navigation_list(VARCHAR) IS 'List navigation items as hierarchical tree. Optionally filter by menu_location. Returns all items including hidden ones for BO management.';

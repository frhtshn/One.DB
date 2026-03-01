-- ================================================================
-- GET_NAVIGATION: Frontend için navigasyon verisi (Tree yapısı)
-- ================================================================
-- Açıklama:
--   Frontend uygulamasının client navigasyonunu çekmesi için.
--   Sadece görünür (is_visible=true) öğeleri döner.
--   Nested tree yapısında döner (children array ile).
-- Kullanım:
--   Website/App frontend tarafından çağrılır.
--   Backoffice için değil, son kullanıcı arayüzü için.
-- ================================================================

DROP FUNCTION IF EXISTS presentation.get_navigation(BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION presentation.get_navigation(
    p_client_id BIGINT,
    p_menu_location VARCHAR(50) DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = presentation, pg_temp
AS $$
DECLARE
    v_result JSONB;
BEGIN
    -- ========================================
    -- 1. CLIENT VARLIK KONTROLÜ
    -- ========================================
    IF NOT EXISTS (SELECT 1 FROM core.clients WHERE id = p_client_id AND status = 1) THEN
        RETURN '[]'::jsonb;
    END IF;

    -- ========================================
    -- 2. RECURSIVE TREE OLUŞTUR
    -- ========================================
    WITH RECURSIVE visible_items AS (
        -- Tüm görünür öğeleri al
        SELECT
            tn.id,
            tn.menu_location,
            tn.translation_key,
            tn.custom_label,
            tn.icon,
            tn.badge_text,
            tn.badge_color,
            tn.target_type,
            tn.target_url,
            tn.target_action,
            tn.open_in_new_tab,
            tn.parent_id,
            tn.display_order,
            tn.requires_auth,
            tn.requires_guest,
            tn.required_roles,
            tn.device_visibility,
            tn.custom_css_class
        FROM presentation.client_navigation tn
        WHERE tn.client_id = p_client_id
          AND tn.is_visible = TRUE
          AND (p_menu_location IS NULL OR tn.menu_location = p_menu_location)
    ),
    -- Her öğe için JSON oluştur
    item_json AS (
        SELECT
            vi.id,
            vi.parent_id,
            vi.menu_location,
            vi.display_order,
            jsonb_build_object(
                'id', vi.id,
                'menuLocation', vi.menu_location,
                'translationKey', vi.translation_key,
                'label', vi.custom_label,
                'icon', vi.icon,
                'badge', CASE
                    WHEN vi.badge_text IS NOT NULL THEN
                        jsonb_build_object('text', vi.badge_text, 'color', vi.badge_color)
                    ELSE NULL
                END,
                'target', jsonb_build_object(
                    'type', vi.target_type,
                    'url', vi.target_url,
                    'action', vi.target_action,
                    'newTab', vi.open_in_new_tab
                ),
                'auth', jsonb_build_object(
                    'requiresAuth', vi.requires_auth,
                    'requiresGuest', vi.requires_guest,
                    'roles', vi.required_roles
                ),
                'device', vi.device_visibility,
                'cssClass', vi.custom_css_class
            ) AS item_data
        FROM visible_items vi
    ),
    -- Children'ları hesapla
    items_with_children AS (
        SELECT
            ij.id,
            ij.parent_id,
            ij.menu_location,
            ij.display_order,
            ij.item_data || jsonb_build_object(
                'children', COALESCE(
                    (SELECT jsonb_agg(
                        child.item_data || jsonb_build_object(
                            'children', COALESCE(
                                (SELECT jsonb_agg(grandchild.item_data ORDER BY grandchild.display_order)
                                 FROM item_json grandchild
                                 WHERE grandchild.parent_id = child.id),
                                '[]'::jsonb
                            )
                        ) ORDER BY child.display_order
                    )
                    FROM item_json child
                    WHERE child.parent_id = ij.id),
                    '[]'::jsonb
                )
            ) AS full_item
        FROM item_json ij
        WHERE ij.parent_id IS NULL  -- Sadece root öğeler
    )
    SELECT COALESCE(
        jsonb_agg(iwc.full_item ORDER BY iwc.menu_location, iwc.display_order),
        '[]'::jsonb
    )
    INTO v_result
    FROM items_with_children iwc;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION presentation.get_navigation(BIGINT, VARCHAR) IS
'Returns visible navigation items as a nested tree structure.
Only returns items where is_visible=TRUE.
Root items have children array with nested descendants.
Supports up to 3 levels of nesting (root -> child -> grandchild).
Usage: Called by website/app frontend, not backoffice.';

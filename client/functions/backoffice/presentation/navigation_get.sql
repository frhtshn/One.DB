-- ================================================================
-- NAVIGATION_GET: Tek menü öğesi detay getir
-- Koruma bayrakları dahil tüm bilgileri döner
-- ================================================================

DROP FUNCTION IF EXISTS presentation.navigation_get(BIGINT);

CREATE OR REPLACE FUNCTION presentation.navigation_get(
    p_id                BIGINT              -- Öğe ID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    -- Parametre doğrulama
    IF p_id IS NULL THEN
        RAISE EXCEPTION 'error.navigation.id-required';
    END IF;

    SELECT jsonb_build_object(
        'id', n.id,
        'templateItemId', n.template_item_id,
        'menuLocation', n.menu_location,
        'translationKey', n.translation_key,
        'customLabel', n.custom_label,
        'icon', n.icon,
        'badgeText', n.badge_text,
        'badgeColor', n.badge_color,
        'targetType', n.target_type,
        'targetUrl', n.target_url,
        'targetAction', n.target_action,
        'openInNewTab', n.open_in_new_tab,
        'parentId', n.parent_id,
        'displayOrder', n.display_order,
        'isVisible', n.is_visible,
        'requiresAuth', n.requires_auth,
        'requiresGuest', n.requires_guest,
        'requiredRoles', n.required_roles,
        'deviceVisibility', n.device_visibility,
        'isLocked', n.is_locked,
        'isReadonly', n.is_readonly,
        'customCssClass', n.custom_css_class,
        'createdAt', n.created_at,
        'updatedAt', n.updated_at
    ) INTO v_result
    FROM presentation.navigation n
    WHERE n.id = p_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION 'error.navigation.item-not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION presentation.navigation_get(BIGINT) IS 'Get single navigation item detail including protection flags (is_locked, is_readonly).';

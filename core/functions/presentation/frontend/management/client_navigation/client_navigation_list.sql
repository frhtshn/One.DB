-- ================================================================
-- TENANT_NAVIGATION_LIST: Tenant navigasyon listesi
-- ================================================================
-- Açıklama:
--   Tenant'ın frontend navigasyon öğelerini listeler.
--   Opsiyonel olarak menu_location ile filtrelenebilir.
-- Erişim:
--   - Platform Admin: Tüm tenant'lar
--   - CompanyAdmin: Kendi company'sindeki tenant'lar
--   - TenantAdmin: user_allowed_tenants'taki tenant'lar
-- ================================================================

DROP FUNCTION IF EXISTS presentation.tenant_navigation_list(BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION presentation.tenant_navigation_list(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_menu_location VARCHAR(50) DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = presentation, core, security, pg_temp
AS $$
DECLARE
    v_result JSONB;
BEGIN
    -- 1. Tenant varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM core.tenants WHERE id = p_tenant_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- 2. Tenant erişim kontrolü
    PERFORM security.user_assert_access_tenant(p_caller_id, p_tenant_id);

    -- ========================================
    -- 3. NAVİGASYON LİSTESİ
    -- ========================================
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', tn.id,
            'templateItemId', tn.template_item_id,
            'menuLocation', tn.menu_location,
            'translationKey', tn.translation_key,
            'customLabel', tn.custom_label,
            'icon', tn.icon,
            'badgeText', tn.badge_text,
            'badgeColor', tn.badge_color,
            'targetType', tn.target_type,
            'targetUrl', tn.target_url,
            'targetAction', tn.target_action,
            'openInNewTab', tn.open_in_new_tab,
            'parentId', tn.parent_id,
            'displayOrder', tn.display_order,
            'isVisible', tn.is_visible,
            'requiresAuth', tn.requires_auth,
            'requiresGuest', tn.requires_guest,
            'requiredRoles', tn.required_roles,
            'deviceVisibility', tn.device_visibility,
            'isLocked', tn.is_locked,
            'isReadonly', tn.is_readonly,
            'customCssClass', tn.custom_css_class,
            'createdAt', tn.created_at,
            'updatedAt', tn.updated_at
        ) ORDER BY tn.menu_location, tn.display_order
    ), '[]'::jsonb)
    INTO v_result
    FROM presentation.tenant_navigation tn
    WHERE tn.tenant_id = p_tenant_id
      AND (p_menu_location IS NULL OR tn.menu_location = p_menu_location);

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION presentation.tenant_navigation_list(BIGINT, BIGINT, VARCHAR) IS
'Lists tenant navigation items, optionally filtered by menu_location.
Access: Platform Admin (all), CompanyAdmin (own company), TenantAdmin (allowed tenants).';

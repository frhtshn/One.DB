-- ================================================================
-- TENANT_NAVIGATION_GET: Navigasyon öğesi detayı
-- ================================================================
-- Açıklama:
--   Belirtilen tenant navigasyon öğesinin detaylarını getirir.
-- Erişim:
--   - Platform Admin: Tüm tenant'lar
--   - CompanyAdmin: Kendi company'sindeki tenant'lar
--   - TenantAdmin: user_allowed_tenants'taki tenant'lar
-- ================================================================

DROP FUNCTION IF EXISTS presentation.tenant_navigation_get(BIGINT, BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION presentation.tenant_navigation_get(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_id BIGINT
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
    -- 3. NAVİGASYON ÖĞESİ GETİR
    -- ========================================
    SELECT jsonb_build_object(
        'id', tn.id,
        'tenantId', tn.tenant_id,
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
    )
    INTO v_result
    FROM presentation.tenant_navigation tn
    WHERE tn.id = p_id AND tn.tenant_id = p_tenant_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant-navigation.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION presentation.tenant_navigation_get(BIGINT, BIGINT, BIGINT) IS
'Gets a tenant navigation item by ID.
Access: Platform Admin (all), CompanyAdmin (own company), TenantAdmin (allowed tenants).';

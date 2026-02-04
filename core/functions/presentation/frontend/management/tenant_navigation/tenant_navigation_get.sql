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
    v_caller_company_id BIGINT;
    v_caller_level INT;
    v_has_platform_role BOOLEAN;
    v_tenant_company_id BIGINT;
    v_has_tenant_access BOOLEAN;
    v_result JSONB;
BEGIN
    -- ========================================
    -- 1. CALLER BİLGİLERİNİ AL
    -- ========================================
    SELECT
        u.company_id,
        COALESCE(MAX(r.level), 0),
        EXISTS(
            SELECT 1 FROM security.user_roles ur2
            JOIN security.roles r2 ON ur2.role_id = r2.id AND r2.status = 1
            WHERE ur2.user_id = u.id AND ur2.tenant_id IS NULL AND r2.is_platform_role = TRUE
        )
    INTO v_caller_company_id, v_caller_level, v_has_platform_role
    FROM security.users u
    LEFT JOIN security.user_roles ur ON ur.user_id = u.id AND ur.tenant_id IS NULL
    LEFT JOIN security.roles r ON r.id = ur.role_id AND r.status = 1
    WHERE u.id = p_caller_id AND u.status = 1
    GROUP BY u.id, u.company_id;

    IF v_caller_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

    -- ========================================
    -- 2. TENANT VARLIK KONTROLÜ
    -- ========================================
    SELECT company_id INTO v_tenant_company_id
    FROM core.tenants WHERE id = p_tenant_id;

    IF v_tenant_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- ========================================
    -- 3. IDOR KONTROLÜ
    -- ========================================
    IF NOT v_has_platform_role THEN
        IF v_caller_level >= 80 THEN
            IF v_tenant_company_id != v_caller_company_id THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.company-scope-denied';
            END IF;
        ELSE
            SELECT EXISTS(
                SELECT 1 FROM security.user_allowed_tenants
                WHERE user_id = p_caller_id AND tenant_id = p_tenant_id
            ) INTO v_has_tenant_access;

            IF NOT v_has_tenant_access THEN
                RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.tenant-scope-denied';
            END IF;
        END IF;
    END IF;

    -- ========================================
    -- 4. NAVİGASYON ÖĞESİ GETİR
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

-- ================================================================
-- TENANT_NAVIGATION_CREATE: Yeni navigasyon öğesi ekle
-- ================================================================
-- Açıklama:
--   Tenant için yeni bir custom navigasyon öğesi oluşturur.
--   Template'den gelmeyen, tenant'ın kendi eklediği öğeler.
-- Erişim:
--   - Platform Admin: Tüm tenant'lar
--   - CompanyAdmin: Kendi company'sindeki tenant'lar
--   - TenantAdmin: user_allowed_tenants'taki tenant'lar
-- ================================================================

DROP FUNCTION IF EXISTS presentation.tenant_navigation_create(
    BIGINT, BIGINT, VARCHAR, VARCHAR, JSONB, VARCHAR, VARCHAR, VARCHAR,
    VARCHAR, VARCHAR, VARCHAR, BOOLEAN, BIGINT, INT, BOOLEAN, BOOLEAN,
    BOOLEAN, VARCHAR[], VARCHAR, VARCHAR
);

CREATE OR REPLACE FUNCTION presentation.tenant_navigation_create(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_menu_location VARCHAR(50),
    p_translation_key VARCHAR(100) DEFAULT NULL,
    p_custom_label JSONB DEFAULT NULL,
    p_icon VARCHAR(50) DEFAULT NULL,
    p_badge_text VARCHAR(20) DEFAULT NULL,
    p_badge_color VARCHAR(20) DEFAULT NULL,
    p_target_type VARCHAR(20) DEFAULT 'internal',
    p_target_url VARCHAR(255) DEFAULT NULL,
    p_target_action VARCHAR(50) DEFAULT NULL,
    p_open_in_new_tab BOOLEAN DEFAULT FALSE,
    p_parent_id BIGINT DEFAULT NULL,
    p_display_order INT DEFAULT 0,
    p_is_visible BOOLEAN DEFAULT TRUE,
    p_requires_auth BOOLEAN DEFAULT FALSE,
    p_requires_guest BOOLEAN DEFAULT FALSE,
    p_required_roles VARCHAR(50)[] DEFAULT NULL,
    p_device_visibility VARCHAR(20) DEFAULT 'all',
    p_custom_css_class VARCHAR(100) DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = presentation, core, security, pg_temp
AS $$
DECLARE
    v_caller_company_id BIGINT;
    v_caller_level INT;
    v_has_platform_role BOOLEAN;
    v_tenant_company_id BIGINT;
    v_has_tenant_access BOOLEAN;
    v_new_id BIGINT;
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
    WHERE u.id = p_caller_id
      AND u.status = 1
      AND u.is_locked = FALSE
      AND (u.locked_until IS NULL OR u.locked_until < NOW())
    GROUP BY u.id, u.company_id;

    IF v_caller_company_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

    -- ========================================
    -- 2. TENANT VARLIK KONTROLÜ
    -- ========================================
    SELECT company_id INTO v_tenant_company_id
    FROM core.tenants WHERE id = p_tenant_id AND status = 1;

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
    -- 4. PARENT VARLIK KONTROLÜ
    -- ========================================
    IF p_parent_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM presentation.tenant_navigation
            WHERE id = p_parent_id AND tenant_id = p_tenant_id
        ) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.tenant-navigation.parent-not-found';
        END IF;
    END IF;

    -- ========================================
    -- 5. NAVİGASYON ÖĞESİ OLUŞTUR
    -- ========================================
    INSERT INTO presentation.tenant_navigation (
        tenant_id,
        template_item_id,
        menu_location,
        translation_key,
        custom_label,
        icon,
        badge_text,
        badge_color,
        target_type,
        target_url,
        target_action,
        open_in_new_tab,
        parent_id,
        display_order,
        is_visible,
        requires_auth,
        requires_guest,
        required_roles,
        device_visibility,
        is_locked,
        is_readonly,
        custom_css_class,
        created_at,
        updated_at
    )
    VALUES (
        p_tenant_id,
        NULL,                    -- template_item_id = NULL (custom item)
        p_menu_location,
        p_translation_key,
        p_custom_label,
        p_icon,
        p_badge_text,
        p_badge_color,
        p_target_type,
        p_target_url,
        p_target_action,
        p_open_in_new_tab,
        p_parent_id,
        p_display_order,
        p_is_visible,
        p_requires_auth,
        p_requires_guest,
        p_required_roles,
        p_device_visibility,
        FALSE,                   -- is_locked = FALSE (custom items can be deleted)
        FALSE,                   -- is_readonly = FALSE (custom items are fully editable)
        p_custom_css_class,
        NOW(),
        NOW()
    )
    RETURNING id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION presentation.tenant_navigation_create IS
'Creates a new custom navigation item for a tenant.
Custom items have is_locked=FALSE and is_readonly=FALSE (fully editable and deletable).
Access: Platform Admin (all), CompanyAdmin (own company), TenantAdmin (allowed tenants).';

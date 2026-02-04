-- ================================================================
-- TENANT_NAVIGATION_UPDATE: Navigasyon öğesi güncelle
-- ================================================================
-- Açıklama:
--   Tenant navigasyon öğesini günceller.
--   is_readonly=TRUE olan öğelerde sadece görünürlük alanları güncellenebilir.
-- Kurallar:
--   - is_readonly=TRUE: Sadece custom_label, icon, badge, display_order, visibility alanları
--   - is_readonly=FALSE: Tüm alanlar güncellenebilir
-- Erişim:
--   - Platform Admin: Tüm tenant'lar
--   - CompanyAdmin: Kendi company'sindeki tenant'lar
--   - TenantAdmin: user_allowed_tenants'taki tenant'lar
-- ================================================================

DROP FUNCTION IF EXISTS presentation.tenant_navigation_update(
    BIGINT, BIGINT, BIGINT, VARCHAR, JSONB, VARCHAR, VARCHAR, VARCHAR,
    VARCHAR, VARCHAR, VARCHAR, BOOLEAN, BIGINT, INT, BOOLEAN, BOOLEAN,
    BOOLEAN, VARCHAR[], VARCHAR, VARCHAR
);

CREATE OR REPLACE FUNCTION presentation.tenant_navigation_update(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_id BIGINT,
    -- Readonly olsa da güncellenebilen alanlar
    p_custom_label JSONB DEFAULT NULL,
    p_icon VARCHAR(50) DEFAULT NULL,
    p_badge_text VARCHAR(20) DEFAULT NULL,
    p_badge_color VARCHAR(20) DEFAULT NULL,
    p_display_order INT DEFAULT NULL,
    p_is_visible BOOLEAN DEFAULT NULL,
    p_requires_auth BOOLEAN DEFAULT NULL,
    p_requires_guest BOOLEAN DEFAULT NULL,
    p_required_roles VARCHAR(50)[] DEFAULT NULL,
    p_device_visibility VARCHAR(20) DEFAULT NULL,
    p_custom_css_class VARCHAR(100) DEFAULT NULL,
    -- Readonly olmayanlarda güncellenebilen alanlar
    p_menu_location VARCHAR(50) DEFAULT NULL,
    p_translation_key VARCHAR(100) DEFAULT NULL,
    p_target_type VARCHAR(20) DEFAULT NULL,
    p_target_url VARCHAR(255) DEFAULT NULL,
    p_target_action VARCHAR(50) DEFAULT NULL,
    p_open_in_new_tab BOOLEAN DEFAULT NULL,
    p_parent_id BIGINT DEFAULT NULL
)
RETURNS VOID
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
    v_item RECORD;
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
    -- 4. MEVCUT ÖĞEYİ AL
    -- ========================================
    SELECT id, is_readonly
    INTO v_item
    FROM presentation.tenant_navigation
    WHERE id = p_id AND tenant_id = p_tenant_id;

    IF v_item.id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant-navigation.not-found';
    END IF;

    -- ========================================
    -- 5. READONLY KONTROLÜ
    -- ========================================
    IF v_item.is_readonly THEN
        -- Sadece görünürlük alanları güncellenebilir
        IF p_menu_location IS NOT NULL OR p_translation_key IS NOT NULL OR
           p_target_type IS NOT NULL OR p_target_url IS NOT NULL OR
           p_target_action IS NOT NULL OR p_open_in_new_tab IS NOT NULL OR
           p_parent_id IS NOT NULL THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.tenant-navigation.readonly-field-update';
        END IF;
    END IF;

    -- ========================================
    -- 6. PARENT VARLIK KONTROLÜ
    -- ========================================
    IF p_parent_id IS NOT NULL THEN
        IF p_parent_id = p_id THEN
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.tenant-navigation.self-parent';
        END IF;

        IF NOT EXISTS (
            SELECT 1 FROM presentation.tenant_navigation
            WHERE id = p_parent_id AND tenant_id = p_tenant_id
        ) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.tenant-navigation.parent-not-found';
        END IF;
    END IF;

    -- ========================================
    -- 7. GÜNCELLE
    -- ========================================
    UPDATE presentation.tenant_navigation
    SET
        -- Her zaman güncellenebilen alanlar
        custom_label = COALESCE(p_custom_label, custom_label),
        icon = COALESCE(p_icon, icon),
        badge_text = COALESCE(p_badge_text, badge_text),
        badge_color = COALESCE(p_badge_color, badge_color),
        display_order = COALESCE(p_display_order, display_order),
        is_visible = COALESCE(p_is_visible, is_visible),
        requires_auth = COALESCE(p_requires_auth, requires_auth),
        requires_guest = COALESCE(p_requires_guest, requires_guest),
        required_roles = COALESCE(p_required_roles, required_roles),
        device_visibility = COALESCE(p_device_visibility, device_visibility),
        custom_css_class = COALESCE(p_custom_css_class, custom_css_class),
        -- Readonly değilse güncellenebilen alanlar
        menu_location = CASE WHEN NOT v_item.is_readonly THEN COALESCE(p_menu_location, menu_location) ELSE menu_location END,
        translation_key = CASE WHEN NOT v_item.is_readonly THEN COALESCE(p_translation_key, translation_key) ELSE translation_key END,
        target_type = CASE WHEN NOT v_item.is_readonly THEN COALESCE(p_target_type, target_type) ELSE target_type END,
        target_url = CASE WHEN NOT v_item.is_readonly THEN COALESCE(p_target_url, target_url) ELSE target_url END,
        target_action = CASE WHEN NOT v_item.is_readonly THEN COALESCE(p_target_action, target_action) ELSE target_action END,
        open_in_new_tab = CASE WHEN NOT v_item.is_readonly THEN COALESCE(p_open_in_new_tab, open_in_new_tab) ELSE open_in_new_tab END,
        parent_id = CASE WHEN NOT v_item.is_readonly THEN COALESCE(p_parent_id, parent_id) ELSE parent_id END,
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION presentation.tenant_navigation_update IS
'Updates a tenant navigation item.
Readonly items (is_readonly=TRUE) can only have visibility fields updated.
Non-readonly items can have all fields updated.
Access: Platform Admin (all), CompanyAdmin (own company), TenantAdmin (allowed tenants).';

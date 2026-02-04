-- ================================================================
-- TENANT_THEME_LIST: Tenant tema listesi
-- ================================================================
-- Açıklama:
--   Tenant'ın yapılandırılmış temalarını listeler.
--   Catalog'daki tüm aktif temaları da gösterir (configured flag ile).
-- Erişim:
--   - Platform Admin: Tüm tenant'lar
--   - CompanyAdmin: Kendi company'sindeki tenant'lar
--   - TenantAdmin: user_allowed_tenants'taki tenant'lar
-- ================================================================

DROP FUNCTION IF EXISTS presentation.tenant_theme_list(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION presentation.tenant_theme_list(
    p_caller_id BIGINT,
    p_tenant_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = presentation, catalog, core, security, pg_temp
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
    -- 4. TEMA LİSTESİ (Catalog + Tenant Config)
    -- ========================================
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'themeId', t.id,
            'code', t.code,
            'name', t.name,
            'description', t.description,
            'version', t.version,
            'thumbnailUrl', t.thumbnail_url,
            'defaultConfig', t.default_config,
            'isPremium', t.is_premium,
            -- Tenant-specific fields
            'tenantThemeId', tt.id,
            'isConfigured', (tt.id IS NOT NULL),
            'isActive', COALESCE(tt.is_active, FALSE),
            'tenantConfig', tt.config,
            'customCss', tt.custom_css
        ) ORDER BY COALESCE(tt.is_active, FALSE) DESC, t.name
    ), '[]'::jsonb)
    INTO v_result
    FROM catalog.themes t
    LEFT JOIN presentation.tenant_themes tt ON tt.theme_id = t.id AND tt.tenant_id = p_tenant_id
    WHERE t.is_active = TRUE;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION presentation.tenant_theme_list(BIGINT, BIGINT) IS
'Lists all available themes with tenant configuration status.
Shows catalog themes with isConfigured and isActive flags based on tenant_themes.
Access: Platform Admin (all), CompanyAdmin (own company), TenantAdmin (allowed tenants).';

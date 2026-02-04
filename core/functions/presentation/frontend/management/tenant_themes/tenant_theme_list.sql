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
    v_result JSONB;
BEGIN
    -- 1. Tenant varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM core.tenants WHERE id = p_tenant_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- 2. Tenant erişim kontrolü
    PERFORM security.user_assert_access_tenant(p_caller_id, p_tenant_id);

    -- 3. Tema listesi (Catalog + Tenant Config)
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

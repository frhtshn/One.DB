-- ================================================================
-- TENANT_THEME_GET: Tenant tema detayı
-- ================================================================
-- Açıklama:
--   Belirtilen tema için tenant yapılandırmasını getirir.
--   Eğer theme_id NULL ise aktif temayı getirir.
--   Merged config (default + override) döner.
-- Erişim:
--   - Platform Admin: Tüm tenant'lar
--   - CompanyAdmin: Kendi company'sindeki tenant'lar
--   - TenantAdmin: user_allowed_tenants'taki tenant'lar
-- ================================================================

DROP FUNCTION IF EXISTS presentation.tenant_theme_get(BIGINT, BIGINT, INT);

CREATE OR REPLACE FUNCTION presentation.tenant_theme_get(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_theme_id INT DEFAULT NULL
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

    -- 3. Tema getir
    IF p_theme_id IS NULL THEN
        -- Aktif temayı getir
        SELECT jsonb_build_object(
            'tenantThemeId', tt.id,
            'themeId', t.id,
            'code', t.code,
            'name', t.name,
            'description', t.description,
            'version', t.version,
            'thumbnailUrl', t.thumbnail_url,
            'defaultConfig', t.default_config,
            'tenantConfig', tt.config,
            'mergedConfig', COALESCE(t.default_config, '{}'::jsonb) || COALESCE(tt.config, '{}'::jsonb),
            'customCss', tt.custom_css,
            'isActive', tt.is_active,
            'isPremium', t.is_premium,
            'createdAt', tt.created_at,
            'updatedAt', tt.updated_at
        )
        INTO v_result
        FROM presentation.tenant_themes tt
        JOIN catalog.themes t ON t.id = tt.theme_id
        WHERE tt.tenant_id = p_tenant_id AND tt.is_active = TRUE;

        IF v_result IS NULL THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant-theme.no-active-theme';
        END IF;
    ELSE
        -- Belirli temayı getir
        SELECT jsonb_build_object(
            'tenantThemeId', tt.id,
            'themeId', t.id,
            'code', t.code,
            'name', t.name,
            'description', t.description,
            'version', t.version,
            'thumbnailUrl', t.thumbnail_url,
            'defaultConfig', t.default_config,
            'tenantConfig', COALESCE(tt.config, '{}'::jsonb),
            'mergedConfig', COALESCE(t.default_config, '{}'::jsonb) || COALESCE(tt.config, '{}'::jsonb),
            'customCss', tt.custom_css,
            'isActive', COALESCE(tt.is_active, FALSE),
            'isConfigured', (tt.id IS NOT NULL),
            'isPremium', t.is_premium,
            'createdAt', tt.created_at,
            'updatedAt', tt.updated_at
        )
        INTO v_result
        FROM catalog.themes t
        LEFT JOIN presentation.tenant_themes tt ON tt.theme_id = t.id AND tt.tenant_id = p_tenant_id
        WHERE t.id = p_theme_id AND t.is_active = TRUE;

        IF v_result IS NULL THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.theme.not-found';
        END IF;
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION presentation.tenant_theme_get(BIGINT, BIGINT, INT) IS
'Gets tenant theme configuration.
If p_theme_id is NULL, returns the active theme.
Returns merged config (default_config + tenant override).
Access: Platform Admin (all), CompanyAdmin (own company), TenantAdmin (allowed tenants).';

-- ================================================================
-- TENANT_THEME_ACTIVATE: Tema aktifleştir
-- ================================================================
-- Açıklama:
--   Belirtilen temayı aktif yapar, diğerlerini deaktif eder.
--   Tema daha önce yapılandırılmamışsa varsayılan ayarlarla oluşturur.
-- Erişim:
--   - Platform Admin: Tüm tenant'lar
--   - CompanyAdmin: Kendi company'sindeki tenant'lar
--   - TenantAdmin: user_allowed_tenants'taki tenant'lar
-- ================================================================

DROP FUNCTION IF EXISTS presentation.tenant_theme_activate(BIGINT, BIGINT, INT);

CREATE OR REPLACE FUNCTION presentation.tenant_theme_activate(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_theme_id INT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = presentation, catalog, core, security, pg_temp
AS $$
BEGIN
    -- 1. Tenant varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM core.tenants WHERE id = p_tenant_id AND status = 1) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- 2. Tenant erişim kontrolü
    PERFORM security.user_assert_access_tenant(p_caller_id, p_tenant_id);

    -- 3. Tema varlık kontrolü
    IF NOT EXISTS (SELECT 1 FROM catalog.themes WHERE id = p_theme_id AND is_active = TRUE) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.theme.not-found';
    END IF;

    -- ========================================
    -- 5. MEVCUT AKTİF TEMAYI DEAKTİF ET
    -- ========================================
    UPDATE presentation.tenant_themes
    SET is_active = FALSE, updated_at = NOW()
    WHERE tenant_id = p_tenant_id AND is_active = TRUE;

    -- ========================================
    -- 6. YENİ TEMAYI AKTİF ET (yoksa oluştur)
    -- ========================================
    INSERT INTO presentation.tenant_themes (
        tenant_id,
        theme_id,
        config,
        is_active,
        created_at,
        updated_at
    )
    VALUES (
        p_tenant_id,
        p_theme_id,
        '{}'::jsonb,
        TRUE,
        NOW(),
        NOW()
    )
    ON CONFLICT (tenant_id, theme_id) DO UPDATE
    SET is_active = TRUE,
        updated_at = NOW();
END;
$$;

COMMENT ON FUNCTION presentation.tenant_theme_activate(BIGINT, BIGINT, INT) IS
'Activates a theme for the tenant.
Deactivates any currently active theme and activates the specified one.
If the theme was not configured before, creates it with default settings.
Access: Platform Admin (all), CompanyAdmin (own company), TenantAdmin (allowed tenants).';

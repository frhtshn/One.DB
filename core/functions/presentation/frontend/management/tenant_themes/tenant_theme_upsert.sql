-- ================================================================
-- TENANT_THEME_UPSERT: Tenant tema yapılandırması oluştur/güncelle
-- ================================================================
-- Açıklama:
--   Tenant için tema yapılandırması oluşturur veya günceller.
--   Config parametresi default_config'i override eder (merge edilir FE'de).
-- Erişim:
--   - Platform Admin: Tüm tenant'lar
--   - CompanyAdmin: Kendi company'sindeki tenant'lar
--   - TenantAdmin: user_allowed_tenants'taki tenant'lar
-- ================================================================

DROP FUNCTION IF EXISTS presentation.tenant_theme_upsert(BIGINT, BIGINT, INT, TEXT, TEXT, BOOLEAN);

CREATE OR REPLACE FUNCTION presentation.tenant_theme_upsert(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_theme_id INT,
    p_config TEXT DEFAULT '{}',
    p_custom_css TEXT DEFAULT NULL,
    p_set_active BOOLEAN DEFAULT FALSE
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = presentation, catalog, core, security, pg_temp
AS $$
DECLARE
    v_tenant_theme_id BIGINT;
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
    -- 5. AKTİF TEMA DEĞİŞİKLİĞİ
    -- ========================================
    IF p_set_active THEN
        -- Diğer temaları deaktif et
        UPDATE presentation.tenant_themes
        SET is_active = FALSE, updated_at = NOW()
        WHERE tenant_id = p_tenant_id AND is_active = TRUE;
    END IF;

    -- ========================================
    -- 6. UPSERT
    -- ========================================
    INSERT INTO presentation.tenant_themes (
        tenant_id,
        theme_id,
        config,
        custom_css,
        is_active,
        created_at,
        updated_at
    )
    VALUES (
        p_tenant_id,
        p_theme_id,
        p_config::jsonb,
        p_custom_css,
        p_set_active,
        NOW(),
        NOW()
    )
    ON CONFLICT (tenant_id, theme_id) DO UPDATE
    SET config = EXCLUDED.config,
        custom_css = EXCLUDED.custom_css,
        is_active = CASE WHEN p_set_active THEN TRUE ELSE presentation.tenant_themes.is_active END,
        updated_at = NOW()
    RETURNING id INTO v_tenant_theme_id;

    RETURN v_tenant_theme_id;
END;
$$;

COMMENT ON FUNCTION presentation.tenant_theme_upsert(BIGINT, BIGINT, INT, TEXT, TEXT, BOOLEAN) IS
'Creates or updates tenant theme configuration.
If p_set_active is TRUE, deactivates other themes and sets this one as active.
Access: Platform Admin (all), CompanyAdmin (own company), TenantAdmin (allowed tenants).';

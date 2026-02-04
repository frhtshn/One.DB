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

DROP FUNCTION IF EXISTS presentation.tenant_theme_upsert(BIGINT, BIGINT, INT, JSONB, TEXT, BOOLEAN);

CREATE OR REPLACE FUNCTION presentation.tenant_theme_upsert(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_theme_id INT,
    p_config JSONB DEFAULT '{}',
    p_custom_css TEXT DEFAULT NULL,
    p_set_active BOOLEAN DEFAULT FALSE
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = presentation, catalog, core, security, pg_temp
AS $$
DECLARE
    v_caller_company_id BIGINT;
    v_caller_level INT;
    v_has_platform_role BOOLEAN;
    v_tenant_company_id BIGINT;
    v_has_tenant_access BOOLEAN;
    v_tenant_theme_id BIGINT;
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
    -- 4. TEMA VARLIK KONTROLÜ
    -- ========================================
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
        p_config,
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

COMMENT ON FUNCTION presentation.tenant_theme_upsert(BIGINT, BIGINT, INT, JSONB, TEXT, BOOLEAN) IS
'Creates or updates tenant theme configuration.
If p_set_active is TRUE, deactivates other themes and sets this one as active.
Access: Platform Admin (all), CompanyAdmin (own company), TenantAdmin (allowed tenants).';

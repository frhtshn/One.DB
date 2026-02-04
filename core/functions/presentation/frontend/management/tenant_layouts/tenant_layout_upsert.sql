-- ================================================================
-- TENANT_LAYOUT_UPSERT: Layout oluştur/güncelle
-- ================================================================
-- Açıklama:
--   Tenant için widget yerleşimi oluşturur veya günceller.
--   layout_name tenant bazında unique'dir.
-- Erişim:
--   - Platform Admin: Tüm tenant'lar
--   - CompanyAdmin: Kendi company'sindeki tenant'lar
--   - TenantAdmin: user_allowed_tenants'taki tenant'lar
-- ================================================================

DROP FUNCTION IF EXISTS presentation.tenant_layout_upsert(BIGINT, BIGINT, VARCHAR, JSONB, BIGINT, BOOLEAN);

CREATE OR REPLACE FUNCTION presentation.tenant_layout_upsert(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_layout_name VARCHAR(50),
    p_structure JSONB,
    p_page_id BIGINT DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT TRUE
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
    v_layout_id BIGINT;
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
    -- 4. UPSERT
    -- ========================================
    INSERT INTO presentation.tenant_layouts (
        tenant_id,
        page_id,
        layout_name,
        structure,
        is_active,
        created_at,
        updated_at
    )
    VALUES (
        p_tenant_id,
        p_page_id,
        p_layout_name,
        p_structure,
        p_is_active,
        NOW(),
        NOW()
    )
    ON CONFLICT (tenant_id, layout_name) DO UPDATE
    SET page_id = EXCLUDED.page_id,
        structure = EXCLUDED.structure,
        is_active = EXCLUDED.is_active,
        updated_at = NOW()
    RETURNING id INTO v_layout_id;

    RETURN v_layout_id;
END;
$$;

COMMENT ON FUNCTION presentation.tenant_layout_upsert(BIGINT, BIGINT, VARCHAR, JSONB, BIGINT, BOOLEAN) IS
'Creates or updates a tenant layout (widget placement).
layout_name is unique per tenant.
Access: Platform Admin (all), CompanyAdmin (own company), TenantAdmin (allowed tenants).';

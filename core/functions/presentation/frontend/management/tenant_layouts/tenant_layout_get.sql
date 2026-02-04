-- ================================================================
-- TENANT_LAYOUT_GET: Tenant layout getir
-- ================================================================
-- Açıklama:
--   Layout'u ID, page_id veya layout_name ile getirir.
-- Erişim:
--   - Platform Admin: Tüm tenant'lar
--   - CompanyAdmin: Kendi company'sindeki tenant'lar
--   - TenantAdmin: user_allowed_tenants'taki tenant'lar
-- ================================================================

DROP FUNCTION IF EXISTS presentation.tenant_layout_get(BIGINT, BIGINT, BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION presentation.tenant_layout_get(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_id BIGINT DEFAULT NULL,
    p_page_id BIGINT DEFAULT NULL,
    p_layout_name VARCHAR(50) DEFAULT NULL
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
    -- 4. PARAMETRE KONTROLÜ
    -- ========================================
    IF p_id IS NULL AND p_page_id IS NULL AND p_layout_name IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.tenant-layout.no-filter';
    END IF;

    -- ========================================
    -- 5. LAYOUT GETİR
    -- ========================================
    SELECT jsonb_build_object(
        'id', tl.id,
        'tenantId', tl.tenant_id,
        'pageId', tl.page_id,
        'layoutName', tl.layout_name,
        'structure', tl.structure,
        'isActive', tl.is_active,
        'createdAt', tl.created_at,
        'updatedAt', tl.updated_at
    )
    INTO v_result
    FROM presentation.tenant_layouts tl
    WHERE tl.tenant_id = p_tenant_id
      AND (p_id IS NULL OR tl.id = p_id)
      AND (p_page_id IS NULL OR tl.page_id = p_page_id)
      AND (p_layout_name IS NULL OR tl.layout_name = p_layout_name);

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant-layout.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION presentation.tenant_layout_get(BIGINT, BIGINT, BIGINT, BIGINT, VARCHAR) IS
'Gets a tenant layout by ID, page_id, or layout_name.
At least one filter must be provided.
Access: Platform Admin (all), CompanyAdmin (own company), TenantAdmin (allowed tenants).';

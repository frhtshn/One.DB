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
    v_result JSONB;
BEGIN
    -- 1. Tenant varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM core.tenants WHERE id = p_tenant_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- 2. Tenant erişim kontrolü
    PERFORM security.user_assert_access_tenant(p_caller_id, p_tenant_id);

    -- 3. Parametre kontrolü
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

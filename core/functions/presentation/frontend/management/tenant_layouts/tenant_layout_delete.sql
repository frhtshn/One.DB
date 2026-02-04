-- ================================================================
-- TENANT_LAYOUT_DELETE: Layout sil
-- ================================================================
-- Açıklama:
--   Tenant layout'unu siler.
-- Erişim:
--   - Platform Admin: Tüm tenant'lar
--   - CompanyAdmin: Kendi company'sindeki tenant'lar
--   - TenantAdmin: user_allowed_tenants'taki tenant'lar
-- ================================================================

DROP FUNCTION IF EXISTS presentation.tenant_layout_delete(BIGINT, BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION presentation.tenant_layout_delete(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = presentation, core, security, pg_temp
AS $$
BEGIN
    -- 1. Tenant varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM core.tenants WHERE id = p_tenant_id AND status = 1) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- 2. Tenant erişim kontrolü
    PERFORM security.user_assert_access_tenant(p_caller_id, p_tenant_id);

    -- 3. Layout varlık kontrolü
    IF NOT EXISTS (
        SELECT 1 FROM presentation.tenant_layouts
        WHERE id = p_id AND tenant_id = p_tenant_id
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant-layout.not-found';
    END IF;

    -- ========================================
    -- 5. SİL
    -- ========================================
    DELETE FROM presentation.tenant_layouts
    WHERE id = p_id AND tenant_id = p_tenant_id;
END;
$$;

COMMENT ON FUNCTION presentation.tenant_layout_delete(BIGINT, BIGINT, BIGINT) IS
'Deletes a tenant layout.
Access: Platform Admin (all), CompanyAdmin (own company), TenantAdmin (allowed tenants).';

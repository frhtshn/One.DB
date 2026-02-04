-- ================================================================
-- TENANT_LAYOUT_LIST: Tenant layout listesi
-- ================================================================
-- Açıklama:
--   Tenant'ın tüm widget yerleşimlerini listeler.
-- Erişim:
--   - Platform Admin: Tüm tenant'lar
--   - CompanyAdmin: Kendi company'sindeki tenant'lar
--   - TenantAdmin: user_allowed_tenants'taki tenant'lar
-- ================================================================

DROP FUNCTION IF EXISTS presentation.tenant_layout_list(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION presentation.tenant_layout_list(
    p_caller_id BIGINT,
    p_tenant_id BIGINT
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

    -- 3. Layout listesi
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', tl.id,
            'tenantId', tl.tenant_id,
            'pageId', tl.page_id,
            'layoutName', tl.layout_name,
            'structure', tl.structure,
            'isActive', tl.is_active,
            'createdAt', tl.created_at,
            'updatedAt', tl.updated_at
        ) ORDER BY tl.layout_name
    ), '[]'::jsonb)
    INTO v_result
    FROM presentation.tenant_layouts tl
    WHERE tl.tenant_id = p_tenant_id;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION presentation.tenant_layout_list(BIGINT, BIGINT) IS
'Lists all tenant layouts (widget placements).
Access: Platform Admin (all), CompanyAdmin (own company), TenantAdmin (allowed tenants).';

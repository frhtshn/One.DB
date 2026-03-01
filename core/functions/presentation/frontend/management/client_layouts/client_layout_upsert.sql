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

DROP FUNCTION IF EXISTS presentation.tenant_layout_upsert(BIGINT, BIGINT, VARCHAR, TEXT, BIGINT, BOOLEAN);

CREATE OR REPLACE FUNCTION presentation.tenant_layout_upsert(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_layout_name VARCHAR(50),
    p_structure TEXT,
    p_page_id BIGINT DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT TRUE
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = presentation, core, security, pg_temp
AS $$
DECLARE
    v_layout_id BIGINT;
BEGIN
    -- 1. Tenant varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM core.tenants WHERE id = p_tenant_id AND status = 1) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- 2. Tenant erişim kontrolü
    PERFORM security.user_assert_access_tenant(p_caller_id, p_tenant_id);

    -- 3. Upsert
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
        p_structure::jsonb,
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

COMMENT ON FUNCTION presentation.tenant_layout_upsert(BIGINT, BIGINT, VARCHAR, TEXT, BIGINT, BOOLEAN) IS
'Creates or updates a tenant layout (widget placement).
layout_name is unique per tenant.
Access: Platform Admin (all), CompanyAdmin (own company), TenantAdmin (allowed tenants).';

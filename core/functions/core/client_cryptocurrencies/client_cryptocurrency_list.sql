-- ================================================================
-- TENANT_CRYPTOCURRENCY_LIST: Tenant kripto para birimlerini listeler
-- Caller ID ile yetki kontrolü
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_cryptocurrency_list(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION core.tenant_cryptocurrency_list(
    p_caller_id BIGINT,
    p_tenant_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result            JSONB;
    v_tenant_company_id BIGINT;
BEGIN
    -- 1. Tenant varlık kontrolü
    SELECT company_id INTO v_tenant_company_id
    FROM core.tenants WHERE id = p_tenant_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- 2. Company erişim kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_tenant_company_id);

    -- 3. Liste oluştur
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', tc.id,
            'tenantId', tc.tenant_id,
            'symbol', tc.symbol,
            'name', c.name,
            'nameFull', c.name_full,
            'iconUrl', c.icon_url,
            'isEnabled', tc.is_enabled,
            'createdAt', tc.created_at,
            'updatedAt', tc.updated_at
        ) ORDER BY tc.is_enabled DESC, c.name
    ), '[]'::jsonb)
    INTO v_result
    FROM core.tenant_cryptocurrencies tc
    JOIN catalog.cryptocurrencies c ON c.symbol = tc.symbol
    WHERE tc.tenant_id = p_tenant_id;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION core.tenant_cryptocurrency_list(BIGINT, BIGINT) IS 'Lists all assigned cryptocurrencies for a tenant. Checks caller permissions.';

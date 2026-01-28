-- ================================================================
-- TENANT_CURRENCY_LIST: Tenant para birimlerini listeler
-- Base currency bilgisini isBase olarak işaretler.
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_currency_list(BIGINT);

CREATE OR REPLACE FUNCTION core.tenant_currency_list(p_tenant_id BIGINT)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_base_currency CHAR(3);
    v_result JSONB;
BEGIN
    -- Get base currency
    SELECT base_currency INTO v_base_currency FROM core.tenants WHERE id = p_tenant_id;

    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', tc.id,
            'tenantId', tc.tenant_id,
            'code', tc.currency_code,
            'name', c.currency_name,
            'symbol', c.symbol,
            'isEnabled', tc.is_enabled,
            'isBase', (tc.currency_code = v_base_currency),
            'createdAt', tc.created_at,
            'updatedAt', tc.updated_at
        ) ORDER BY (tc.currency_code = v_base_currency) DESC, tc.is_enabled DESC, c.currency_name
    ), '[]'::jsonb)
    INTO v_result
    FROM core.tenant_currencies tc
    JOIN catalog.currencies c ON c.currency_code = tc.currency_code
    WHERE tc.tenant_id = p_tenant_id;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION core.tenant_currency_list(BIGINT) IS 'Lists all assigned currencies for a tenant.';

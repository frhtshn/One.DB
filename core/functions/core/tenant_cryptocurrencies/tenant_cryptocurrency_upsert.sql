-- ================================================================
-- TENANT_CRYPTOCURRENCY_UPSERT: Tenant kripto para birimi ekle/güncelle
-- Caller ID ile yetki kontrolü
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_cryptocurrency_upsert(BIGINT, BIGINT, VARCHAR, BOOLEAN);

CREATE OR REPLACE FUNCTION core.tenant_cryptocurrency_upsert(
    p_caller_id  BIGINT,
    p_tenant_id  BIGINT,
    p_symbol     VARCHAR(20),
    p_is_enabled BOOLEAN DEFAULT TRUE
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_tenant_company_id BIGINT;
    v_symbol            VARCHAR(20);
BEGIN
    v_symbol := UPPER(TRIM(p_symbol));

    -- 1. Tenant varlık kontrolü
    SELECT company_id INTO v_tenant_company_id
    FROM core.tenants WHERE id = p_tenant_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- 2. Company erişim kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_tenant_company_id);

    -- 3. Cryptocurrency varlık kontrolü
    IF NOT EXISTS (SELECT 1 FROM catalog.cryptocurrencies WHERE symbol = v_symbol AND is_active = TRUE) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.cryptocurrency.not-found';
    END IF;

    -- 4. Upsert logic
    IF EXISTS (SELECT 1 FROM core.tenant_cryptocurrencies WHERE tenant_id = p_tenant_id AND symbol = v_symbol) THEN
        UPDATE core.tenant_cryptocurrencies
        SET is_enabled = p_is_enabled,
            updated_at = NOW()
        WHERE tenant_id = p_tenant_id AND symbol = v_symbol;
    ELSE
        INSERT INTO core.tenant_cryptocurrencies (tenant_id, symbol, is_enabled)
        VALUES (p_tenant_id, v_symbol, p_is_enabled);
    END IF;
END;
$$;

COMMENT ON FUNCTION core.tenant_cryptocurrency_upsert(BIGINT, BIGINT, VARCHAR, BOOLEAN) IS 'Assigns or updates a cryptocurrency for a tenant. Checks caller permissions.';

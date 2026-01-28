-- ================================================================
-- TENANT_CURRENCY_UPSERT: Tenant para birimi ekle/güncelle
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_currency_upsert(BIGINT, CHAR(3), BOOLEAN);

CREATE OR REPLACE FUNCTION core.tenant_currency_upsert(
    p_tenant_id BIGINT,
    p_currency_code CHAR(3),
    p_is_enabled BOOLEAN DEFAULT TRUE
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Validations
    IF NOT EXISTS (SELECT 1 FROM core.tenants WHERE id = p_tenant_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM catalog.currencies WHERE currency_code = p_currency_code AND is_active = TRUE) THEN
         RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.currency.not-found';
    END IF;

    -- Upsert Logic (Assuming unique constraint on tenant_id + currency_code exists or handled manually)
    -- Checking schema: tenant_currencies usually has (tenant_id, currency_code) unique.

    IF EXISTS (SELECT 1 FROM core.tenant_currencies WHERE tenant_id = p_tenant_id AND currency_code = p_currency_code) THEN
        UPDATE core.tenant_currencies
        SET is_enabled = p_is_enabled,
            updated_at = NOW()
        WHERE tenant_id = p_tenant_id AND currency_code = p_currency_code;
    ELSE
        INSERT INTO core.tenant_currencies (tenant_id, currency_code, is_enabled)
        VALUES (p_tenant_id, p_currency_code, p_is_enabled);
    END IF;
END;
$$;

COMMENT ON FUNCTION core.tenant_currency_upsert(BIGINT, CHAR(3), BOOLEAN) IS 'Assigns or updates a currency for a tenant.';

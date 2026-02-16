-- ================================================================
-- TENANT_PAYMENT_PROVIDER_DISABLE: Tenant payment provider kapatma
-- ================================================================
-- Sadece flag günceller (is_enabled=false).
-- Ödeme metotlarına (core.tenant_payment_methods) DOKUNMAZ.
-- Provider durumu sorgu seviyesinde filtrelenir.
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_payment_provider_disable(BIGINT, BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION core.tenant_payment_provider_disable(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_provider_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_company_id BIGINT;
BEGIN
    -- Tenant varlık kontrolü
    SELECT company_id INTO v_company_id
    FROM core.tenants WHERE id = p_tenant_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant.not-found';
    END IF;

    -- IDOR kontrolü
    PERFORM security.user_assert_access_company(p_caller_id, v_company_id);

    -- Provider kaydı kontrolü
    IF NOT EXISTS(
        SELECT 1 FROM core.tenant_providers
        WHERE tenant_id = p_tenant_id AND provider_id = p_provider_id
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant-provider.not-found';
    END IF;

    -- Sadece flag güncelle
    UPDATE core.tenant_providers
    SET is_enabled = false, updated_at = NOW()
    WHERE tenant_id = p_tenant_id AND provider_id = p_provider_id;
END;
$$;

COMMENT ON FUNCTION core.tenant_payment_provider_disable IS 'Disables a payment provider for tenant (flag only). Payment methods remain untouched - provider status is filtered at query level.';

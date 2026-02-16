-- ================================================================
-- TENANT_PAYMENT_METHOD_REMOVE: Tenant ödeme metotu kapatma (soft delete)
-- ================================================================
-- is_enabled=false + disabled_reason ayarlar.
-- sync_status='pending' ile tenant DB'ye de yansıtılır.
-- ================================================================

DROP FUNCTION IF EXISTS core.tenant_payment_method_remove(BIGINT, BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION core.tenant_payment_method_remove(
    p_caller_id BIGINT,
    p_tenant_id BIGINT,
    p_payment_method_id BIGINT,
    p_disabled_reason VARCHAR(255) DEFAULT NULL
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

    -- payment_method_id zorunlu
    IF p_payment_method_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.id-required';
    END IF;

    -- Kayıt kontrolü + güncelleme
    UPDATE core.tenant_payment_methods SET
        is_enabled = false,
        disabled_at = NOW(),
        disabled_reason = COALESCE(p_disabled_reason, 'disabled_by_admin'),
        sync_status = 'pending',
        updated_at = NOW(),
        updated_by = p_caller_id
    WHERE tenant_id = p_tenant_id AND payment_method_id = p_payment_method_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.tenant-payment-method.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION core.tenant_payment_method_remove IS 'Soft-disables a tenant payment method (is_enabled=false) with optional reason. Sets sync_status=pending for tenant DB propagation. IDOR protected.';

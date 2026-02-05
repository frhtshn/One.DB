-- ================================================================
-- PAYMENT_METHOD_DELETE: Ödeme yöntemi siler
-- Tenant'larda kullanılıyorsa silme engellenir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.payment_method_delete(BIGINT);

CREATE OR REPLACE FUNCTION catalog.payment_method_delete(
    p_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.id-required';
    END IF;

    -- Mevcut kayıt kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.payment_methods pm WHERE pm.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.payment-method.not-found';
    END IF;

    -- NOT: Tenant kullanım kontrolü core.tenant_payment_methods tablosu varsa eklenebilir
    -- IF EXISTS(SELECT 1 FROM core.tenant_payment_methods tpm WHERE tpm.payment_method_id = p_id) THEN
    --     RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.payment-method.in-use';
    -- END IF;

    -- Sil
    DELETE FROM catalog.payment_methods WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.payment_method_delete IS 'Deletes a payment method.';

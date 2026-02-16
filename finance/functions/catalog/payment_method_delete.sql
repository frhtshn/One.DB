-- ================================================================
-- PAYMENT_METHOD_DELETE: Ödeme yöntemi kapatır (soft delete)
-- ================================================================
-- Core DB'deki hard delete'ten soft delete'e dönüştürüldü.
-- is_active = false yapılır, kayıt silinmez.
-- Finance DB catalog'un sahibidir.
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

    -- Soft delete
    UPDATE catalog.payment_methods
    SET is_active = false, updated_at = NOW()
    WHERE id = p_id AND is_active = true;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.payment-method.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION catalog.payment_method_delete(BIGINT) IS 'Soft-deletes a payment method (is_active=false). Migrated from Core DB hard delete to Finance DB soft delete pattern.';

-- ================================================================
-- PAYMENT_METHOD_SETTINGS_REMOVE: Ödeme metodu devre dışı bırak (soft delete)
-- ================================================================
-- is_enabled=false yapar. Fiziksel DELETE yok.
-- payment_method_limits kayıtları korunur.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS finance.payment_method_settings_remove(BIGINT);

CREATE OR REPLACE FUNCTION finance.payment_method_settings_remove(
    p_payment_method_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_payment_method_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.id-required';
    END IF;

    UPDATE finance.payment_method_settings
    SET is_enabled = false, updated_at = NOW()
    WHERE payment_method_id = p_payment_method_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.payment-method.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION finance.payment_method_settings_remove(BIGINT) IS 'Soft-disables a payment method in tenant DB (is_enabled=false). No physical DELETE, payment_method_limits preserved. Auth-agnostic.';

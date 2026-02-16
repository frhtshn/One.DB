-- ================================================================
-- PAYMENT_METHOD_LIMIT_LIST: Ödeme metot limit listesi
-- ================================================================
-- Aktif limitleri döner (is_active=true varsayılan).
-- currency_type, currency_code sıralı.
-- Auth-agnostic.
-- ================================================================

DROP FUNCTION IF EXISTS finance.payment_method_limit_list(BIGINT);

CREATE OR REPLACE FUNCTION finance.payment_method_limit_list(
    p_payment_method_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_payment_method_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.id-required';
    END IF;

    IF NOT EXISTS(SELECT 1 FROM finance.payment_method_settings WHERE payment_method_id = p_payment_method_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.payment-method.not-found';
    END IF;

    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'currencyCode', pml.currency_code,
            'currencyType', pml.currency_type,
            'minDeposit', pml.min_deposit,
            'maxDeposit', pml.max_deposit,
            'dailyDepositLimit', pml.daily_deposit_limit,
            'weeklyDepositLimit', pml.weekly_deposit_limit,
            'monthlyDepositLimit', pml.monthly_deposit_limit,
            'minWithdrawal', pml.min_withdrawal,
            'maxWithdrawal', pml.max_withdrawal,
            'dailyWithdrawalLimit', pml.daily_withdrawal_limit,
            'weeklyWithdrawalLimit', pml.weekly_withdrawal_limit,
            'monthlyWithdrawalLimit', pml.monthly_withdrawal_limit,
            'depositFeePercent', pml.deposit_fee_percent,
            'depositFeeFixed', pml.deposit_fee_fixed,
            'depositFeeMin', pml.deposit_fee_min,
            'depositFeeMax', pml.deposit_fee_max,
            'withdrawalFeePercent', pml.withdrawal_fee_percent,
            'withdrawalFeeFixed', pml.withdrawal_fee_fixed,
            'withdrawalFeeMin', pml.withdrawal_fee_min,
            'withdrawalFeeMax', pml.withdrawal_fee_max,
            'isActive', pml.is_active
        ) ORDER BY pml.currency_type, pml.currency_code
    ), '[]'::jsonb)
    INTO v_result
    FROM finance.payment_method_limits pml
    WHERE pml.payment_method_id = p_payment_method_id AND pml.is_active = true;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION finance.payment_method_limit_list(BIGINT) IS 'Returns active currency limits for a payment method with deposit/withdrawal limits, fees, and fee min/max. Ordered by currency_type then currency_code. Auth-agnostic.';

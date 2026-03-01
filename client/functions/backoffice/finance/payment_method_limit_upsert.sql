-- ================================================================
-- PAYMENT_METHOD_LIMIT_UPSERT: Ödeme metot limiti ekle/güncelle
-- ================================================================
-- (payment_method_id, currency_code) bazlı UPSERT.
-- Client override olarak kaydedilir.
-- Auth-agnostic.
-- ================================================================

DROP FUNCTION IF EXISTS finance.payment_method_limit_upsert(
    BIGINT, VARCHAR, SMALLINT,
    DECIMAL, DECIMAL, DECIMAL, DECIMAL, DECIMAL,
    DECIMAL, DECIMAL, DECIMAL, DECIMAL, DECIMAL,
    DECIMAL, DECIMAL, DECIMAL, DECIMAL,
    DECIMAL, DECIMAL, DECIMAL, DECIMAL
);

CREATE OR REPLACE FUNCTION finance.payment_method_limit_upsert(
    p_payment_method_id BIGINT,
    p_currency_code VARCHAR(20),
    p_currency_type SMALLINT DEFAULT 1,
    p_min_deposit DECIMAL(18,8) DEFAULT NULL,
    p_max_deposit DECIMAL(18,8) DEFAULT NULL,
    p_daily_deposit_limit DECIMAL(18,8) DEFAULT NULL,
    p_weekly_deposit_limit DECIMAL(18,8) DEFAULT NULL,
    p_monthly_deposit_limit DECIMAL(18,8) DEFAULT NULL,
    p_min_withdrawal DECIMAL(18,8) DEFAULT NULL,
    p_max_withdrawal DECIMAL(18,8) DEFAULT NULL,
    p_daily_withdrawal_limit DECIMAL(18,8) DEFAULT NULL,
    p_weekly_withdrawal_limit DECIMAL(18,8) DEFAULT NULL,
    p_monthly_withdrawal_limit DECIMAL(18,8) DEFAULT NULL,
    p_deposit_fee_percent DECIMAL(5,4) DEFAULT NULL,
    p_deposit_fee_fixed DECIMAL(18,8) DEFAULT NULL,
    p_deposit_fee_min DECIMAL(18,8) DEFAULT NULL,
    p_deposit_fee_max DECIMAL(18,8) DEFAULT NULL,
    p_withdrawal_fee_percent DECIMAL(5,4) DEFAULT NULL,
    p_withdrawal_fee_fixed DECIMAL(18,8) DEFAULT NULL,
    p_withdrawal_fee_min DECIMAL(18,8) DEFAULT NULL,
    p_withdrawal_fee_max DECIMAL(18,8) DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Parametre kontrolleri
    IF p_payment_method_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.id-required';
    END IF;

    IF p_currency_code IS NULL OR TRIM(p_currency_code) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.currency-code-required';
    END IF;

    IF p_min_deposit IS NULL OR p_max_deposit IS NULL OR p_min_withdrawal IS NULL OR p_max_withdrawal IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.limits-required';
    END IF;

    -- payment_method_settings'te mevcut olmalı
    IF NOT EXISTS(SELECT 1 FROM finance.payment_method_settings WHERE payment_method_id = p_payment_method_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.payment-method.not-found';
    END IF;

    -- UPSERT
    INSERT INTO finance.payment_method_limits (
        payment_method_id, currency_code, currency_type,
        min_deposit, max_deposit, daily_deposit_limit, weekly_deposit_limit, monthly_deposit_limit,
        min_withdrawal, max_withdrawal, daily_withdrawal_limit, weekly_withdrawal_limit, monthly_withdrawal_limit,
        deposit_fee_percent, deposit_fee_fixed, deposit_fee_min, deposit_fee_max,
        withdrawal_fee_percent, withdrawal_fee_fixed, withdrawal_fee_min, withdrawal_fee_max,
        is_active, created_at, updated_at
    ) VALUES (
        p_payment_method_id,
        UPPER(TRIM(p_currency_code)),
        COALESCE(p_currency_type, 1),
        p_min_deposit,
        p_max_deposit,
        p_daily_deposit_limit,
        p_weekly_deposit_limit,
        p_monthly_deposit_limit,
        p_min_withdrawal,
        p_max_withdrawal,
        p_daily_withdrawal_limit,
        p_weekly_withdrawal_limit,
        p_monthly_withdrawal_limit,
        p_deposit_fee_percent,
        p_deposit_fee_fixed,
        p_deposit_fee_min,
        p_deposit_fee_max,
        p_withdrawal_fee_percent,
        p_withdrawal_fee_fixed,
        p_withdrawal_fee_min,
        p_withdrawal_fee_max,
        true,
        NOW(),
        NOW()
    )
    ON CONFLICT (payment_method_id, currency_code) DO UPDATE SET
        currency_type = COALESCE(p_currency_type, finance.payment_method_limits.currency_type),
        min_deposit = p_min_deposit,
        max_deposit = p_max_deposit,
        daily_deposit_limit = COALESCE(p_daily_deposit_limit, finance.payment_method_limits.daily_deposit_limit),
        weekly_deposit_limit = COALESCE(p_weekly_deposit_limit, finance.payment_method_limits.weekly_deposit_limit),
        monthly_deposit_limit = COALESCE(p_monthly_deposit_limit, finance.payment_method_limits.monthly_deposit_limit),
        min_withdrawal = p_min_withdrawal,
        max_withdrawal = p_max_withdrawal,
        daily_withdrawal_limit = COALESCE(p_daily_withdrawal_limit, finance.payment_method_limits.daily_withdrawal_limit),
        weekly_withdrawal_limit = COALESCE(p_weekly_withdrawal_limit, finance.payment_method_limits.weekly_withdrawal_limit),
        monthly_withdrawal_limit = COALESCE(p_monthly_withdrawal_limit, finance.payment_method_limits.monthly_withdrawal_limit),
        deposit_fee_percent = COALESCE(p_deposit_fee_percent, finance.payment_method_limits.deposit_fee_percent),
        deposit_fee_fixed = COALESCE(p_deposit_fee_fixed, finance.payment_method_limits.deposit_fee_fixed),
        deposit_fee_min = COALESCE(p_deposit_fee_min, finance.payment_method_limits.deposit_fee_min),
        deposit_fee_max = COALESCE(p_deposit_fee_max, finance.payment_method_limits.deposit_fee_max),
        withdrawal_fee_percent = COALESCE(p_withdrawal_fee_percent, finance.payment_method_limits.withdrawal_fee_percent),
        withdrawal_fee_fixed = COALESCE(p_withdrawal_fee_fixed, finance.payment_method_limits.withdrawal_fee_fixed),
        withdrawal_fee_min = COALESCE(p_withdrawal_fee_min, finance.payment_method_limits.withdrawal_fee_min),
        withdrawal_fee_max = COALESCE(p_withdrawal_fee_max, finance.payment_method_limits.withdrawal_fee_max),
        is_active = true,
        updated_at = NOW();
END;
$$;

COMMENT ON FUNCTION finance.payment_method_limit_upsert IS 'Upserts per-method currency limit with deposit/withdrawal limits, fees, and fee min/max (client override). Supports fiat (type=1) and crypto (type=2). Auth-agnostic.';

-- ================================================================
-- PAYMENT_METHOD_CURRENCY_LIMIT_SYNC: Currency limit toplu senkronizasyon
-- ================================================================
-- p_limits TEXT → JSONB array cast.
-- Mevcut kayıtlar güncellenir, yeniler eklenir.
-- Artık desteklenmeyen limitler is_active=false yapılır.
-- BO admin paneli veya provider sync tarafından kullanılır.
-- ================================================================

DROP FUNCTION IF EXISTS catalog.payment_method_currency_limit_sync(BIGINT, TEXT);

CREATE OR REPLACE FUNCTION catalog.payment_method_currency_limit_sync(
    p_payment_method_id BIGINT,
    p_limits TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_limits JSONB;
    v_elem JSONB;
    v_synced_currencies VARCHAR(20)[] := '{}';
BEGIN
    -- Parametre kontrolleri
    IF p_payment_method_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.id-required';
    END IF;

    IF NOT EXISTS(SELECT 1 FROM catalog.payment_methods WHERE id = p_payment_method_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.payment-method.not-found';
    END IF;

    IF p_limits IS NULL OR TRIM(p_limits) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.limits-data-required';
    END IF;

    v_limits := p_limits::JSONB;

    IF jsonb_typeof(v_limits) != 'array' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.limits-invalid-format';
    END IF;

    -- Her eleman için UPSERT
    FOR v_elem IN SELECT * FROM jsonb_array_elements(v_limits)
    LOOP
        INSERT INTO catalog.payment_method_currency_limits (
            payment_method_id, currency_code, currency_type,
            min_deposit, max_deposit, daily_deposit_limit, monthly_deposit_limit,
            min_withdrawal, max_withdrawal, daily_withdrawal_limit, monthly_withdrawal_limit,
            deposit_fee_percent, deposit_fee_fixed,
            withdrawal_fee_percent, withdrawal_fee_fixed,
            is_active, created_at, updated_at
        ) VALUES (
            p_payment_method_id,
            UPPER(TRIM(v_elem->>'currency_code')),
            COALESCE((v_elem->>'currency_type')::SMALLINT, 1),
            (v_elem->>'min_deposit')::DECIMAL(18,8),
            (v_elem->>'max_deposit')::DECIMAL(18,8),
            (v_elem->>'daily_deposit_limit')::DECIMAL(18,8),
            (v_elem->>'monthly_deposit_limit')::DECIMAL(18,8),
            (v_elem->>'min_withdrawal')::DECIMAL(18,8),
            (v_elem->>'max_withdrawal')::DECIMAL(18,8),
            (v_elem->>'daily_withdrawal_limit')::DECIMAL(18,8),
            (v_elem->>'monthly_withdrawal_limit')::DECIMAL(18,8),
            COALESCE((v_elem->>'deposit_fee_percent')::DECIMAL(5,4), 0),
            COALESCE((v_elem->>'deposit_fee_fixed')::DECIMAL(18,8), 0),
            COALESCE((v_elem->>'withdrawal_fee_percent')::DECIMAL(5,4), 0),
            COALESCE((v_elem->>'withdrawal_fee_fixed')::DECIMAL(18,8), 0),
            true,
            NOW(),
            NOW()
        )
        ON CONFLICT (payment_method_id, currency_code) DO UPDATE SET
            currency_type = COALESCE((v_elem->>'currency_type')::SMALLINT, catalog.payment_method_currency_limits.currency_type),
            min_deposit = (v_elem->>'min_deposit')::DECIMAL(18,8),
            max_deposit = (v_elem->>'max_deposit')::DECIMAL(18,8),
            daily_deposit_limit = (v_elem->>'daily_deposit_limit')::DECIMAL(18,8),
            monthly_deposit_limit = (v_elem->>'monthly_deposit_limit')::DECIMAL(18,8),
            min_withdrawal = (v_elem->>'min_withdrawal')::DECIMAL(18,8),
            max_withdrawal = (v_elem->>'max_withdrawal')::DECIMAL(18,8),
            daily_withdrawal_limit = (v_elem->>'daily_withdrawal_limit')::DECIMAL(18,8),
            monthly_withdrawal_limit = (v_elem->>'monthly_withdrawal_limit')::DECIMAL(18,8),
            deposit_fee_percent = COALESCE((v_elem->>'deposit_fee_percent')::DECIMAL(5,4), 0),
            deposit_fee_fixed = COALESCE((v_elem->>'deposit_fee_fixed')::DECIMAL(18,8), 0),
            withdrawal_fee_percent = COALESCE((v_elem->>'withdrawal_fee_percent')::DECIMAL(5,4), 0),
            withdrawal_fee_fixed = COALESCE((v_elem->>'withdrawal_fee_fixed')::DECIMAL(18,8), 0),
            is_active = true,
            updated_at = NOW();

        v_synced_currencies := array_append(v_synced_currencies, UPPER(TRIM(v_elem->>'currency_code')));
    END LOOP;

    -- Artık desteklenmeyen limitleri soft delete
    UPDATE catalog.payment_method_currency_limits
    SET is_active = false, updated_at = NOW()
    WHERE payment_method_id = p_payment_method_id
      AND is_active = true
      AND currency_code != ALL(v_synced_currencies);
END;
$$;

COMMENT ON FUNCTION catalog.payment_method_currency_limit_sync(BIGINT, TEXT) IS 'Syncs per-method currency limits in Finance DB catalog. Accepts TEXT->JSONB array with deposit/withdrawal limits and fees. Limits not in payload are soft-deleted (is_active=false).';

-- ================================================================
-- PAYMENT_PLAYER_LIMIT_SET: Player ödeme limiti ekle/güncelle
-- ================================================================
-- (player_id, payment_method_id, currency_code) bazlı UPSERT.
-- limit_type: self_imposed, responsible_gaming, admin_imposed
-- Denormalize payment_method_code saklanır.
-- Auth-agnostic (backend çağırır — hem player self hem admin).
-- ================================================================

DROP FUNCTION IF EXISTS finance.payment_player_limit_set(
    BIGINT, BIGINT, VARCHAR, VARCHAR, SMALLINT,
    DECIMAL, DECIMAL, DECIMAL, DECIMAL,
    DECIMAL, DECIMAL, DECIMAL, DECIMAL,
    VARCHAR
);

CREATE OR REPLACE FUNCTION finance.payment_player_limit_set(
    p_player_id BIGINT,
    p_payment_method_id BIGINT,
    p_payment_method_code VARCHAR(100),
    p_currency_code VARCHAR(20),
    p_currency_type SMALLINT DEFAULT 1,
    p_min_deposit DECIMAL(18,8) DEFAULT NULL,
    p_max_deposit DECIMAL(18,8) DEFAULT NULL,
    p_min_withdrawal DECIMAL(18,8) DEFAULT NULL,
    p_max_withdrawal DECIMAL(18,8) DEFAULT NULL,
    p_daily_deposit_limit DECIMAL(18,8) DEFAULT NULL,
    p_daily_withdrawal_limit DECIMAL(18,8) DEFAULT NULL,
    p_monthly_deposit_limit DECIMAL(18,8) DEFAULT NULL,
    p_monthly_withdrawal_limit DECIMAL(18,8) DEFAULT NULL,
    p_limit_type VARCHAR(50) DEFAULT 'admin_imposed'
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Parametre kontrolleri
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player.id-required';
    END IF;

    IF p_payment_method_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.id-required';
    END IF;

    IF p_currency_code IS NULL OR TRIM(p_currency_code) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.currency-code-required';
    END IF;

    -- limit_type validasyon
    IF p_limit_type IS NOT NULL AND p_limit_type NOT IN ('self_imposed', 'responsible_gaming', 'admin_imposed') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player-limit.invalid-type';
    END IF;

    -- UPSERT
    INSERT INTO finance.payment_player_limits (
        player_id, payment_method_id, payment_method_code,
        currency_code, currency_type,
        min_deposit, max_deposit, min_withdrawal, max_withdrawal,
        daily_deposit_limit, daily_withdrawal_limit,
        monthly_deposit_limit, monthly_withdrawal_limit,
        limit_type,
        created_at, updated_at
    ) VALUES (
        p_player_id,
        p_payment_method_id,
        COALESCE(p_payment_method_code, ''),
        UPPER(TRIM(p_currency_code)),
        COALESCE(p_currency_type, 1),
        p_min_deposit,
        p_max_deposit,
        p_min_withdrawal,
        p_max_withdrawal,
        p_daily_deposit_limit,
        p_daily_withdrawal_limit,
        p_monthly_deposit_limit,
        p_monthly_withdrawal_limit,
        COALESCE(p_limit_type, 'admin_imposed'),
        NOW(),
        NOW()
    )
    ON CONFLICT (player_id, payment_method_id, currency_code) DO UPDATE SET
        payment_method_code = COALESCE(p_payment_method_code, finance.payment_player_limits.payment_method_code),
        currency_type = COALESCE(p_currency_type, finance.payment_player_limits.currency_type),
        min_deposit = COALESCE(p_min_deposit, finance.payment_player_limits.min_deposit),
        max_deposit = COALESCE(p_max_deposit, finance.payment_player_limits.max_deposit),
        min_withdrawal = COALESCE(p_min_withdrawal, finance.payment_player_limits.min_withdrawal),
        max_withdrawal = COALESCE(p_max_withdrawal, finance.payment_player_limits.max_withdrawal),
        daily_deposit_limit = COALESCE(p_daily_deposit_limit, finance.payment_player_limits.daily_deposit_limit),
        daily_withdrawal_limit = COALESCE(p_daily_withdrawal_limit, finance.payment_player_limits.daily_withdrawal_limit),
        monthly_deposit_limit = COALESCE(p_monthly_deposit_limit, finance.payment_player_limits.monthly_deposit_limit),
        monthly_withdrawal_limit = COALESCE(p_monthly_withdrawal_limit, finance.payment_player_limits.monthly_withdrawal_limit),
        limit_type = COALESCE(p_limit_type, finance.payment_player_limits.limit_type),
        updated_at = NOW();
END;
$$;

COMMENT ON FUNCTION finance.payment_player_limit_set IS 'Upserts player-specific payment limit per method and currency. Supports self_imposed, responsible_gaming, and admin_imposed types. COALESCE on update preserves existing values. Auth-agnostic.';

-- ================================================================
-- PLAYER_FINANCIAL_LIMIT_SET: Oyuncu genel finansal limit ekle/güncelle
-- ================================================================
-- (player_id, currency_code, limit_type) bazlı UPSERT.
-- Ödeme yönteminden bağımsız global limitler + responsible gaming.
-- limit_type: self_imposed, admin_imposed
-- Aynı oyuncu+currency için iki tip limit olabilir; backend en
-- kısıtlayıcıyı uygular.
-- Auth-agnostic (backend çağırır — hem player self hem admin).
-- ================================================================

DROP FUNCTION IF EXISTS finance.player_financial_limit_set(
    BIGINT, VARCHAR, SMALLINT,
    DECIMAL, DECIMAL, DECIMAL,
    DECIMAL, DECIMAL, DECIMAL,
    DECIMAL, DECIMAL, DECIMAL,
    DECIMAL, DECIMAL, DECIMAL,
    VARCHAR
);

CREATE OR REPLACE FUNCTION finance.player_financial_limit_set(
    p_player_id BIGINT,
    p_currency_code VARCHAR(20),
    p_currency_type SMALLINT DEFAULT 1,
    p_daily_deposit_limit DECIMAL(18,8) DEFAULT NULL,
    p_weekly_deposit_limit DECIMAL(18,8) DEFAULT NULL,
    p_monthly_deposit_limit DECIMAL(18,8) DEFAULT NULL,
    p_daily_withdrawal_limit DECIMAL(18,8) DEFAULT NULL,
    p_weekly_withdrawal_limit DECIMAL(18,8) DEFAULT NULL,
    p_monthly_withdrawal_limit DECIMAL(18,8) DEFAULT NULL,
    p_daily_loss_limit DECIMAL(18,8) DEFAULT NULL,
    p_weekly_loss_limit DECIMAL(18,8) DEFAULT NULL,
    p_monthly_loss_limit DECIMAL(18,8) DEFAULT NULL,
    p_daily_wager_limit DECIMAL(18,8) DEFAULT NULL,
    p_weekly_wager_limit DECIMAL(18,8) DEFAULT NULL,
    p_monthly_wager_limit DECIMAL(18,8) DEFAULT NULL,
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

    IF p_currency_code IS NULL OR TRIM(p_currency_code) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.financial-limit.currency-code-required';
    END IF;

    -- limit_type validasyon
    IF p_limit_type IS NULL OR p_limit_type NOT IN ('self_imposed', 'admin_imposed') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.financial-limit.invalid-type';
    END IF;

    -- UPSERT
    INSERT INTO finance.player_financial_limits (
        player_id, currency_code, currency_type,
        daily_deposit_limit, weekly_deposit_limit, monthly_deposit_limit,
        daily_withdrawal_limit, weekly_withdrawal_limit, monthly_withdrawal_limit,
        daily_loss_limit, weekly_loss_limit, monthly_loss_limit,
        daily_wager_limit, weekly_wager_limit, monthly_wager_limit,
        limit_type,
        created_at, updated_at
    ) VALUES (
        p_player_id,
        UPPER(TRIM(p_currency_code)),
        COALESCE(p_currency_type, 1),
        p_daily_deposit_limit,
        p_weekly_deposit_limit,
        p_monthly_deposit_limit,
        p_daily_withdrawal_limit,
        p_weekly_withdrawal_limit,
        p_monthly_withdrawal_limit,
        p_daily_loss_limit,
        p_weekly_loss_limit,
        p_monthly_loss_limit,
        p_daily_wager_limit,
        p_weekly_wager_limit,
        p_monthly_wager_limit,
        p_limit_type,
        NOW(),
        NOW()
    )
    ON CONFLICT (player_id, currency_code, limit_type) DO UPDATE SET
        currency_type       = COALESCE(p_currency_type, finance.player_financial_limits.currency_type),
        daily_deposit_limit    = COALESCE(p_daily_deposit_limit, finance.player_financial_limits.daily_deposit_limit),
        weekly_deposit_limit   = COALESCE(p_weekly_deposit_limit, finance.player_financial_limits.weekly_deposit_limit),
        monthly_deposit_limit  = COALESCE(p_monthly_deposit_limit, finance.player_financial_limits.monthly_deposit_limit),
        daily_withdrawal_limit    = COALESCE(p_daily_withdrawal_limit, finance.player_financial_limits.daily_withdrawal_limit),
        weekly_withdrawal_limit   = COALESCE(p_weekly_withdrawal_limit, finance.player_financial_limits.weekly_withdrawal_limit),
        monthly_withdrawal_limit  = COALESCE(p_monthly_withdrawal_limit, finance.player_financial_limits.monthly_withdrawal_limit),
        daily_loss_limit    = COALESCE(p_daily_loss_limit, finance.player_financial_limits.daily_loss_limit),
        weekly_loss_limit   = COALESCE(p_weekly_loss_limit, finance.player_financial_limits.weekly_loss_limit),
        monthly_loss_limit  = COALESCE(p_monthly_loss_limit, finance.player_financial_limits.monthly_loss_limit),
        daily_wager_limit   = COALESCE(p_daily_wager_limit, finance.player_financial_limits.daily_wager_limit),
        weekly_wager_limit  = COALESCE(p_weekly_wager_limit, finance.player_financial_limits.weekly_wager_limit),
        monthly_wager_limit = COALESCE(p_monthly_wager_limit, finance.player_financial_limits.monthly_wager_limit),
        updated_at = NOW();
END;
$$;

COMMENT ON FUNCTION finance.player_financial_limit_set IS 'Upserts player global financial limit per currency and type. Supports deposit/withdrawal caps and responsible gaming limits (loss/wager). COALESCE on update preserves existing values. Auth-agnostic.';

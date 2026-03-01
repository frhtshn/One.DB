-- ================================================================
-- PLAYER_FINANCIAL_LIMIT_GET: Oyuncu genel finansal limit detayı
-- ================================================================
-- Player'ın belirli currency+limit_type kombinasyonuna ait
-- global finansal limitlerini döner.
-- NULL dönerse limit tanımlı değil — backend site limitini uygular.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS finance.player_financial_limit_get(BIGINT, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION finance.player_financial_limit_get(
    p_player_id BIGINT,
    p_currency_code VARCHAR(20),
    p_limit_type VARCHAR(50) DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    -- Parametre kontrolleri
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player.id-required';
    END IF;

    IF p_currency_code IS NULL OR TRIM(p_currency_code) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.financial-limit.currency-code-required';
    END IF;

    SELECT jsonb_build_object(
        'playerId', pfl.player_id,
        'currencyCode', pfl.currency_code,
        'currencyType', pfl.currency_type,
        'dailyDepositLimit', pfl.daily_deposit_limit,
        'weeklyDepositLimit', pfl.weekly_deposit_limit,
        'monthlyDepositLimit', pfl.monthly_deposit_limit,
        'dailyWithdrawalLimit', pfl.daily_withdrawal_limit,
        'weeklyWithdrawalLimit', pfl.weekly_withdrawal_limit,
        'monthlyWithdrawalLimit', pfl.monthly_withdrawal_limit,
        'dailyLossLimit', pfl.daily_loss_limit,
        'weeklyLossLimit', pfl.weekly_loss_limit,
        'monthlyLossLimit', pfl.monthly_loss_limit,
        'dailyWagerLimit', pfl.daily_wager_limit,
        'weeklyWagerLimit', pfl.weekly_wager_limit,
        'monthlyWagerLimit', pfl.monthly_wager_limit,
        'limitType', pfl.limit_type,
        'createdAt', pfl.created_at,
        'updatedAt', pfl.updated_at
    )
    INTO v_result
    FROM finance.player_financial_limits pfl
    WHERE pfl.player_id = p_player_id
      AND pfl.currency_code = UPPER(TRIM(p_currency_code))
      AND (p_limit_type IS NULL OR pfl.limit_type = p_limit_type);

    -- NULL dönmesi hata değil — limit tanımlı değilse NULL döner
    -- Backend bu durumda site limiti uygular
    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION finance.player_financial_limit_get(BIGINT, VARCHAR, VARCHAR) IS 'Returns player global financial limit for a currency and optional limit type. Returns NULL if no limit defined (backend applies site-level limit). Auth-agnostic.';

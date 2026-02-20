-- ================================================================
-- PLAYER_FINANCIAL_LIMIT_LIST: Oyuncu tüm genel finansal limitleri
-- ================================================================
-- Player'ın tanımlı tüm global finansal limitlerini döner.
-- Opsiyonel limit_type filtresi (self_imposed / admin_imposed).
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS finance.player_financial_limit_list(BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION finance.player_financial_limit_list(
    p_player_id BIGINT,
    p_limit_type VARCHAR(50) DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.player.id-required';
    END IF;

    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
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
        ) ORDER BY pfl.limit_type, pfl.currency_type, pfl.currency_code
    ), '[]'::jsonb)
    INTO v_result
    FROM finance.player_financial_limits pfl
    WHERE pfl.player_id = p_player_id
      AND (p_limit_type IS NULL OR pfl.limit_type = p_limit_type);

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION finance.player_financial_limit_list(BIGINT, VARCHAR) IS 'Returns all player global financial limits. Optional limit_type filter. Ordered by type, currency_type, currency_code. Auth-agnostic.';

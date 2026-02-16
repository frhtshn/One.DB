-- ================================================================
-- PAYMENT_PLAYER_LIMIT_LIST: Player tüm limitleri
-- ================================================================
-- Player'ın tanımlı tüm özel limitlerini döner.
-- Opsiyonel payment_method_id filtresi.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS finance.payment_player_limit_list(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION finance.payment_player_limit_list(
    p_player_id BIGINT,
    p_payment_method_id BIGINT DEFAULT NULL
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
            'paymentMethodId', ppl.payment_method_id,
            'paymentMethodCode', ppl.payment_method_code,
            'currencyCode', ppl.currency_code,
            'currencyType', ppl.currency_type,
            'minDeposit', ppl.min_deposit,
            'maxDeposit', ppl.max_deposit,
            'minWithdrawal', ppl.min_withdrawal,
            'maxWithdrawal', ppl.max_withdrawal,
            'dailyDepositLimit', ppl.daily_deposit_limit,
            'dailyWithdrawalLimit', ppl.daily_withdrawal_limit,
            'monthlyDepositLimit', ppl.monthly_deposit_limit,
            'monthlyWithdrawalLimit', ppl.monthly_withdrawal_limit,
            'limitType', ppl.limit_type,
            'createdAt', ppl.created_at,
            'updatedAt', ppl.updated_at
        ) ORDER BY ppl.payment_method_id, ppl.currency_type, ppl.currency_code
    ), '[]'::jsonb)
    INTO v_result
    FROM finance.payment_player_limits ppl
    WHERE ppl.player_id = p_player_id
      AND (p_payment_method_id IS NULL OR ppl.payment_method_id = p_payment_method_id);

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION finance.payment_player_limit_list(BIGINT, BIGINT) IS 'Returns all player-specific payment limits. Optional payment_method_id filter. Ordered by method, currency_type, currency_code. Auth-agnostic.';

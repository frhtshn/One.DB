-- ================================================================
-- PAYMENT_PLAYER_LIMIT_GET: Player metot+currency limiti
-- ================================================================
-- Cashier limit kontrolü: player'ın belirli bir metot+currency
-- kombinasyonuna özel limitlerini döner.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS finance.payment_player_limit_get(BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION finance.payment_player_limit_get(
    p_player_id BIGINT,
    p_payment_method_id BIGINT,
    p_currency_code VARCHAR(20)
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

    IF p_payment_method_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.id-required';
    END IF;

    IF p_currency_code IS NULL OR TRIM(p_currency_code) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.payment-method.currency-code-required';
    END IF;

    SELECT jsonb_build_object(
        'playerId', ppl.player_id,
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
    )
    INTO v_result
    FROM finance.payment_player_limits ppl
    WHERE ppl.player_id = p_player_id
      AND ppl.payment_method_id = p_payment_method_id
      AND ppl.currency_code = UPPER(TRIM(p_currency_code));

    -- NULL dönmesi hata değil — limit tanımlı değilse NULL döner
    -- Backend bu durumda site limiti uygular
    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION finance.payment_player_limit_get(BIGINT, BIGINT, VARCHAR) IS 'Returns player-specific limit for a payment method and currency. Returns NULL if no limit defined (backend applies site-level limit). Auth-agnostic.';

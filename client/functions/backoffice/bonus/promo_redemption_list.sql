-- ================================================================
-- PROMO_REDEMPTION_LIST: Oyuncu promo kullanım geçmişi
-- ================================================================
-- Auth-agnostic. Oyuncunun tüm promo kod kullanımlarını döner.
-- Bonus award bilgisi dahil (varsa).
-- ================================================================

DROP FUNCTION IF EXISTS bonus.promo_redemption_list(BIGINT);

CREATE OR REPLACE FUNCTION bonus.promo_redemption_list(
    p_player_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.promo.player-required';
    END IF;

    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', pr.id,
            'promoCodeId', pr.promo_code_id,
            'promoCode', pr.promo_code,
            'bonusAwardId', pr.bonus_award_id,
            'status', pr.status,
            'failureReason', pr.failure_reason,
            'redeemedAt', pr.redeemed_at,
            'awardAmount', ba.bonus_amount,
            'awardCurrency', ba.currency,
            'awardStatus', ba.status
        ) ORDER BY pr.redeemed_at DESC
    ), '[]'::jsonb)
    INTO v_result
    FROM bonus.promo_redemptions pr
    LEFT JOIN bonus.bonus_awards ba ON ba.id = pr.bonus_award_id
    WHERE pr.player_id = p_player_id;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION bonus.promo_redemption_list(BIGINT) IS 'Lists player promo code redemption history with linked award info (amount, currency, status). Ordered by redeemed_at descending.';

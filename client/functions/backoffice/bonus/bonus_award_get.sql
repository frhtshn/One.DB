-- ================================================================
-- BONUS_AWARD_GET: Tekil bonus award detay
-- ================================================================
-- Auth-agnostic. Player veya BO tarafından çağrılır.
-- Çevrim ilerlemesi yüzde olarak hesaplanır.
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_award_get(BIGINT);

CREATE OR REPLACE FUNCTION bonus.bonus_award_get(
    p_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-award.id-required';
    END IF;

    SELECT jsonb_build_object(
        'id', ba.id,
        'playerId', ba.player_id,
        'bonusRuleId', ba.bonus_rule_id,
        'bonusTypeCode', ba.bonus_type_code,
        'bonusSubtype', ba.bonus_subtype,
        'promoCodeId', ba.promo_code_id,
        'campaignId', ba.campaign_id,
        'bonusAmount', ba.bonus_amount,
        'currency', ba.currency,
        'currentBalance', ba.current_balance,
        'wageringTarget', ba.wagering_target,
        'wageringProgress', ba.wagering_progress,
        'wageringCompleted', ba.wagering_completed,
        'wageringPercent', CASE
            WHEN ba.wagering_target IS NOT NULL AND ba.wagering_target > 0
            THEN ROUND((ba.wagering_progress / ba.wagering_target) * 100, 2)
            ELSE NULL
        END,
        'maxWithdrawalAmount', ba.max_withdrawal_amount,
        'usageCriteria', ba.usage_criteria,
        'rewardDetails', ba.reward_details,
        'expiresAt', ba.expires_at,
        'status', ba.status,
        'clientTransactionId', ba.client_transaction_id,
        'completionTransactionId', ba.completion_transaction_id,
        'awardedBy', ba.awarded_by,
        'cancellationReason', ba.cancellation_reason,
        'cancelledBy', ba.cancelled_by,
        'awardedAt', ba.awarded_at,
        'completedAt', ba.completed_at,
        'cancelledAt', ba.cancelled_at,
        'createdAt', ba.created_at
    )
    INTO v_result
    FROM bonus.bonus_awards ba
    WHERE ba.id = p_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.bonus-award.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION bonus.bonus_award_get(BIGINT) IS 'Returns single bonus award detail with wagering progress percentage and all audit fields.';

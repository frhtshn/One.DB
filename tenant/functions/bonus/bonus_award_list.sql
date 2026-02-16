-- ================================================================
-- BONUS_AWARD_LIST: Oyuncu bonus listesi
-- ================================================================
-- Auth-agnostic. Oyuncunun tüm bonus award'larını döner.
-- Filtre: status, bonus_type_code.
-- FE'de per-bonus çevrim progress bar için kullanılır.
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_award_list(BIGINT, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION bonus.bonus_award_list(
    p_player_id BIGINT,
    p_status VARCHAR(20) DEFAULT NULL,
    p_bonus_type_code VARCHAR(50) DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-award.player-required';
    END IF;

    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', ba.id,
            'bonusRuleId', ba.bonus_rule_id,
            'bonusTypeCode', ba.bonus_type_code,
            'bonusSubtype', ba.bonus_subtype,
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
            'expiresAt', ba.expires_at,
            'status', ba.status,
            'awardedAt', ba.awarded_at
        ) ORDER BY ba.expires_at ASC NULLS LAST, ba.awarded_at ASC
    ), '[]'::jsonb)
    INTO v_result
    FROM bonus.bonus_awards ba
    WHERE ba.player_id = p_player_id
      AND (p_status IS NULL OR ba.status = p_status)
      AND (p_bonus_type_code IS NULL OR ba.bonus_type_code = p_bonus_type_code);

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION bonus.bonus_award_list(BIGINT, VARCHAR, VARCHAR) IS 'Lists player bonus awards with wagering progress. Ordered by expiry (FIFO spending priority). Used for FE per-bonus progress bars.';

-- ================================================================
-- PROMO_CODE_GET: Tekil promo kod detay
-- ================================================================
-- Bonus rule bilgisi ve kullanım istatistikleri dahil.
-- ================================================================

DROP FUNCTION IF EXISTS promotion.promo_code_get(BIGINT);

CREATE OR REPLACE FUNCTION promotion.promo_code_get(
    p_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.promo.id-required';
    END IF;

    SELECT jsonb_build_object(
        'id', pc.id,
        'clientId', pc.client_id,
        'code', pc.code,
        'promoName', pc.promo_name,
        'bonusRuleId', pc.bonus_rule_id,
        'bonusRuleCode', br.rule_code,
        'bonusRuleName', br.rule_name,
        'maxRedemptions', pc.max_redemptions,
        'maxPerPlayer', pc.max_per_player,
        'currentRedemptions', pc.current_redemptions,
        'remainingRedemptions', CASE
            WHEN pc.max_redemptions IS NOT NULL
            THEN GREATEST(pc.max_redemptions - pc.current_redemptions, 0)
            ELSE NULL
        END,
        'validFrom', pc.valid_from,
        'validUntil', pc.valid_until,
        'isActive', pc.is_active,
        'createdAt', pc.created_at,
        'updatedAt', pc.updated_at
    )
    INTO v_result
    FROM promotion.promo_codes pc
    JOIN bonus.bonus_rules br ON br.id = pc.bonus_rule_id
    WHERE pc.id = p_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.promo.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION promotion.promo_code_get(BIGINT) IS 'Returns single promotional code detail with bonus rule info and remaining redemption count.';

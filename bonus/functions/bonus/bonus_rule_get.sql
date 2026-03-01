-- ================================================================
-- BONUS_RULE_GET: Tekil bonus kuralı detay
-- ================================================================
-- Tüm 6 JSONB bileşen + tip bilgisi + kullanım istatistikleri.
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_rule_get(BIGINT);

CREATE OR REPLACE FUNCTION bonus.bonus_rule_get(
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
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-rule.id-required';
    END IF;

    SELECT jsonb_build_object(
        'id', br.id,
        'clientId', br.client_id,
        'ruleCode', br.rule_code,
        'ruleName', br.rule_name,
        'bonusTypeId', br.bonus_type_id,
        'bonusTypeCode', bt.type_code,
        'bonusTypeName', bt.type_name,
        'category', bt.category,
        'triggerConfig', br.trigger_config,
        'dataConfig', br.data_config,
        'eligibilityCriteria', br.eligibility_criteria,
        'rewardConfig', br.reward_config,
        'usageCriteria', br.usage_criteria,
        'targetConfig', br.target_config,
        'evaluationType', br.evaluation_type,
        'maxUsesTotal', br.max_uses_total,
        'maxUsesPerPlayer', br.max_uses_per_player,
        'currentUsesTotal', br.current_uses_total,
        'validFrom', br.valid_from,
        'validUntil', br.valid_until,
        'disablesOtherBonuses', br.disables_other_bonuses,
        'stackingGroup', br.stacking_group,
        'isActive', br.is_active,
        'createdAt', br.created_at,
        'updatedAt', br.updated_at
    )
    INTO v_result
    FROM bonus.bonus_rules br
    JOIN bonus.bonus_types bt ON bt.id = br.bonus_type_id
    WHERE br.id = p_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.bonus-rule.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION bonus.bonus_rule_get(BIGINT) IS 'Returns single bonus rule with all 6 JSONB components, bonus type info, and usage statistics.';

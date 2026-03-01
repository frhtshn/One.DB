-- ================================================================
-- BONUS_RULE_LIST: Bonus kuralı listesi
-- ================================================================
-- Filtre: client_id, bonus_type_id, evaluation_type, is_active.
-- Platform seviyesi kurallar (client_id=NULL) dahil edilir.
-- JSONB bileşenler listelemede döndürülmez (performans).
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_rule_list(BIGINT, BIGINT, VARCHAR, BOOLEAN);

CREATE OR REPLACE FUNCTION bonus.bonus_rule_list(
    p_client_id BIGINT DEFAULT NULL,
    p_bonus_type_id BIGINT DEFAULT NULL,
    p_evaluation_type VARCHAR(20) DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', br.id,
            'clientId', br.client_id,
            'ruleCode', br.rule_code,
            'ruleName', br.rule_name,
            'bonusTypeId', br.bonus_type_id,
            'bonusTypeCode', bt.type_code,
            'category', bt.category,
            'evaluationType', br.evaluation_type,
            'maxUsesTotal', br.max_uses_total,
            'currentUsesTotal', br.current_uses_total,
            'maxUsesPerPlayer', br.max_uses_per_player,
            'validFrom', br.valid_from,
            'validUntil', br.valid_until,
            'disablesOtherBonuses', br.disables_other_bonuses,
            'stackingGroup', br.stacking_group,
            'isActive', br.is_active,
            'createdAt', br.created_at
        ) ORDER BY br.created_at DESC
    ), '[]'::jsonb)
    INTO v_result
    FROM bonus.bonus_rules br
    JOIN bonus.bonus_types bt ON bt.id = br.bonus_type_id
    WHERE (p_client_id IS NULL OR br.client_id IS NULL OR br.client_id = p_client_id)
      AND (p_bonus_type_id IS NULL OR br.bonus_type_id = p_bonus_type_id)
      AND (p_evaluation_type IS NULL OR br.evaluation_type = p_evaluation_type)
      AND (p_is_active IS NULL OR br.is_active = p_is_active);

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION bonus.bonus_rule_list(BIGINT, BIGINT, VARCHAR, BOOLEAN) IS 'Lists bonus rules with filters. Includes platform-level rules (client_id=NULL). JSONB components excluded for performance — use bonus_rule_get for full detail.';

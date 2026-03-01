-- ================================================================
-- BONUS_RULE_UPDATE: Bonus kuralı güncelle
-- ================================================================
-- COALESCE pattern: NULL = mevcut değeri koru.
-- JSONB bileşenler ayrı ayrı güncellenebilir.
-- current_uses_total bu fonksiyonla güncellenemez (atomik).
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_rule_update(BIGINT, VARCHAR, VARCHAR, BIGINT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, VARCHAR, INT, INT, TIMESTAMPTZ, TIMESTAMPTZ, BOOLEAN, VARCHAR, BOOLEAN);

CREATE OR REPLACE FUNCTION bonus.bonus_rule_update(
    p_id BIGINT,
    p_rule_code VARCHAR(100) DEFAULT NULL,
    p_rule_name VARCHAR(255) DEFAULT NULL,
    p_bonus_type_id BIGINT DEFAULT NULL,
    p_trigger_config TEXT DEFAULT NULL,
    p_reward_config TEXT DEFAULT NULL,
    p_data_config TEXT DEFAULT NULL,
    p_eligibility_criteria TEXT DEFAULT NULL,
    p_usage_criteria TEXT DEFAULT NULL,
    p_target_config TEXT DEFAULT NULL,
    p_evaluation_type VARCHAR(20) DEFAULT NULL,
    p_max_uses_total INT DEFAULT NULL,
    p_max_uses_per_player INT DEFAULT NULL,
    p_valid_from TIMESTAMPTZ DEFAULT NULL,
    p_valid_until TIMESTAMPTZ DEFAULT NULL,
    p_disables_other_bonuses BOOLEAN DEFAULT NULL,
    p_stacking_group VARCHAR(50) DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_current RECORD;
BEGIN
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-rule.id-required';
    END IF;

    SELECT id, client_id, rule_code INTO v_current
    FROM bonus.bonus_rules WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.bonus-rule.not-found';
    END IF;

    -- rule_code değişiyorsa unique kontrolü
    IF p_rule_code IS NOT NULL AND UPPER(TRIM(p_rule_code)) != v_current.rule_code THEN
        IF EXISTS (
            SELECT 1 FROM bonus.bonus_rules
            WHERE client_id IS NOT DISTINCT FROM v_current.client_id
              AND rule_code = UPPER(TRIM(p_rule_code))
              AND id != p_id
        ) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.bonus-rule.code-exists';
        END IF;
    END IF;

    -- bonus_type_id değişiyorsa varlık kontrolü
    IF p_bonus_type_id IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM bonus.bonus_types WHERE id = p_bonus_type_id AND is_active = true) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.bonus-type.not-found-or-inactive';
        END IF;
    END IF;

    -- evaluation_type validasyon
    IF p_evaluation_type IS NOT NULL AND p_evaluation_type NOT IN ('immediate', 'periodic', 'manual', 'claim') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-rule.invalid-evaluation-type';
    END IF;

    UPDATE bonus.bonus_rules SET
        rule_code = COALESCE(UPPER(TRIM(NULLIF(p_rule_code, ''))), rule_code),
        rule_name = COALESCE(TRIM(NULLIF(p_rule_name, '')), rule_name),
        bonus_type_id = COALESCE(p_bonus_type_id, bonus_type_id),
        trigger_config = CASE WHEN p_trigger_config IS NOT NULL THEN p_trigger_config::JSONB ELSE trigger_config END,
        reward_config = CASE WHEN p_reward_config IS NOT NULL THEN p_reward_config::JSONB ELSE reward_config END,
        data_config = CASE WHEN p_data_config IS NOT NULL THEN p_data_config::JSONB ELSE data_config END,
        eligibility_criteria = CASE WHEN p_eligibility_criteria IS NOT NULL THEN p_eligibility_criteria::JSONB ELSE eligibility_criteria END,
        usage_criteria = CASE WHEN p_usage_criteria IS NOT NULL THEN p_usage_criteria::JSONB ELSE usage_criteria END,
        target_config = CASE WHEN p_target_config IS NOT NULL THEN p_target_config::JSONB ELSE target_config END,
        evaluation_type = COALESCE(p_evaluation_type, evaluation_type),
        max_uses_total = COALESCE(p_max_uses_total, max_uses_total),
        max_uses_per_player = COALESCE(p_max_uses_per_player, max_uses_per_player),
        valid_from = COALESCE(p_valid_from, valid_from),
        valid_until = COALESCE(p_valid_until, valid_until),
        disables_other_bonuses = COALESCE(p_disables_other_bonuses, disables_other_bonuses),
        stacking_group = COALESCE(p_stacking_group, stacking_group),
        is_active = COALESCE(p_is_active, is_active),
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION bonus.bonus_rule_update IS 'Updates a bonus rule. COALESCE pattern preserves existing values. JSONB components individually updatable. current_uses_total is atomic-only (not updatable here).';

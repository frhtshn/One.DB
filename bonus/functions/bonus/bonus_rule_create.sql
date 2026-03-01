-- ================================================================
-- BONUS_RULE_CREATE: Bonus kuralı oluştur
-- ================================================================
-- 6 JSONB bileşen ile bonus kuralı tanımlar.
-- trigger_config ve reward_config zorunlu.
-- Unique: (client_id, rule_code).
-- bonus_type_id mevcut ve aktif olmalı.
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_rule_create(BIGINT, VARCHAR, VARCHAR, BIGINT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, VARCHAR, INT, INT, TIMESTAMPTZ, TIMESTAMPTZ, BOOLEAN, VARCHAR);

CREATE OR REPLACE FUNCTION bonus.bonus_rule_create(
    p_client_id BIGINT,
    p_rule_code VARCHAR(100),
    p_rule_name VARCHAR(255),
    p_bonus_type_id BIGINT,
    p_trigger_config TEXT,
    p_reward_config TEXT,
    p_data_config TEXT DEFAULT NULL,
    p_eligibility_criteria TEXT DEFAULT NULL,
    p_usage_criteria TEXT DEFAULT NULL,
    p_target_config TEXT DEFAULT NULL,
    p_evaluation_type VARCHAR(20) DEFAULT 'immediate',
    p_max_uses_total INT DEFAULT NULL,
    p_max_uses_per_player INT DEFAULT 1,
    p_valid_from TIMESTAMPTZ DEFAULT NULL,
    p_valid_until TIMESTAMPTZ DEFAULT NULL,
    p_disables_other_bonuses BOOLEAN DEFAULT false,
    p_stacking_group VARCHAR(50) DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_new_id BIGINT;
BEGIN
    -- Zorunlu alan kontrolleri
    IF p_rule_code IS NULL OR TRIM(p_rule_code) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-rule.code-required';
    END IF;

    IF p_rule_name IS NULL OR TRIM(p_rule_name) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-rule.name-required';
    END IF;

    IF p_trigger_config IS NULL OR TRIM(p_trigger_config) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-rule.trigger-config-required';
    END IF;

    IF p_reward_config IS NULL OR TRIM(p_reward_config) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-rule.reward-config-required';
    END IF;

    -- bonus_type_id kontrolü
    IF NOT EXISTS (SELECT 1 FROM bonus.bonus_types WHERE id = p_bonus_type_id AND is_active = true) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.bonus-type.not-found-or-inactive';
    END IF;

    -- evaluation_type validasyon
    IF p_evaluation_type NOT IN ('immediate', 'periodic', 'manual', 'claim') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-rule.invalid-evaluation-type';
    END IF;

    -- Unique kod kontrolü
    IF EXISTS (
        SELECT 1 FROM bonus.bonus_rules
        WHERE client_id IS NOT DISTINCT FROM p_client_id
          AND rule_code = UPPER(TRIM(p_rule_code))
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.bonus-rule.code-exists';
    END IF;

    INSERT INTO bonus.bonus_rules (
        client_id, rule_code, rule_name, bonus_type_id,
        trigger_config, data_config, eligibility_criteria,
        reward_config, usage_criteria, target_config,
        evaluation_type,
        max_uses_total, max_uses_per_player, current_uses_total,
        valid_from, valid_until,
        disables_other_bonuses, stacking_group,
        is_active, created_at, updated_at
    ) VALUES (
        p_client_id,
        UPPER(TRIM(p_rule_code)),
        TRIM(p_rule_name),
        p_bonus_type_id,
        p_trigger_config::JSONB,
        CASE WHEN p_data_config IS NOT NULL THEN p_data_config::JSONB ELSE NULL END,
        CASE WHEN p_eligibility_criteria IS NOT NULL THEN p_eligibility_criteria::JSONB ELSE NULL END,
        p_reward_config::JSONB,
        CASE WHEN p_usage_criteria IS NOT NULL THEN p_usage_criteria::JSONB ELSE NULL END,
        CASE WHEN p_target_config IS NOT NULL THEN p_target_config::JSONB ELSE NULL END,
        p_evaluation_type,
        p_max_uses_total,
        p_max_uses_per_player,
        0,
        p_valid_from,
        p_valid_until,
        COALESCE(p_disables_other_bonuses, false),
        p_stacking_group,
        true,
        NOW(), NOW()
    )
    RETURNING id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION bonus.bonus_rule_create IS 'Creates a bonus rule with 6 JSONB components (trigger, data, eligibility, reward, usage, target). TEXT params cast to JSONB internally. Unique by (client_id, rule_code).';

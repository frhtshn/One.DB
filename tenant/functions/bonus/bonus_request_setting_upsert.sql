-- ================================================================
-- BONUS_REQUEST_SETTING_UPSERT: Bonus talep ayarı oluştur/güncelle
-- ================================================================
-- Tenant bazlı bonus talep ayarını UPSERT eder.
-- bonus_type_code + is_active = true üzerinden conflict.
-- JSONB alanları (display_name, rules_content, eligible_*,
-- default_usage_criteria) TEXT olarak alınır, fonksiyon içinde parse edilir.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_request_setting_upsert(VARCHAR, TEXT, TEXT, BOOLEAN, TEXT, TEXT, INT, INT, INT, INT, INT, INT, TEXT, INT);

CREATE OR REPLACE FUNCTION bonus.bonus_request_setting_upsert(
    p_bonus_type_code           VARCHAR(50),
    p_display_name              TEXT,
    p_rules_content             TEXT DEFAULT NULL,
    p_is_requestable            BOOLEAN DEFAULT false,
    p_eligible_groups           TEXT DEFAULT NULL,
    p_eligible_categories       TEXT DEFAULT NULL,
    p_min_group_level           INT DEFAULT NULL,
    p_min_category_level        INT DEFAULT NULL,
    p_cooldown_after_approved   INT DEFAULT 30,
    p_cooldown_after_rejected   INT DEFAULT 3,
    p_max_pending_per_player    INT DEFAULT 1,
    p_max_description_length    INT DEFAULT 500,
    p_default_usage_criteria    TEXT DEFAULT NULL,
    p_display_order             INT DEFAULT 0
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id                BIGINT;
    v_display_name      JSONB;
    v_rules_content     JSONB;
    v_eligible_groups   JSONB;
    v_eligible_categories JSONB;
    v_usage_criteria    JSONB;
BEGIN
    -- Zorunlu alan kontrolü
    IF p_bonus_type_code IS NULL OR p_bonus_type_code = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request.type-required';
    END IF;

    IF p_display_name IS NULL OR p_display_name = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request-settings.display-name-required';
    END IF;

    -- JSONB parse
    BEGIN
        v_display_name := p_display_name::JSONB;
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request-settings.invalid-display-name';
    END;

    IF p_rules_content IS NOT NULL AND p_rules_content <> '' THEN
        BEGIN
            v_rules_content := p_rules_content::JSONB;
        EXCEPTION WHEN OTHERS THEN
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request-settings.invalid-rules-content';
        END;
    END IF;

    IF p_eligible_groups IS NOT NULL AND p_eligible_groups <> '' THEN
        BEGIN
            v_eligible_groups := p_eligible_groups::JSONB;
        EXCEPTION WHEN OTHERS THEN
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request-settings.invalid-eligible-groups';
        END;
    END IF;

    IF p_eligible_categories IS NOT NULL AND p_eligible_categories <> '' THEN
        BEGIN
            v_eligible_categories := p_eligible_categories::JSONB;
        EXCEPTION WHEN OTHERS THEN
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request-settings.invalid-eligible-categories';
        END;
    END IF;

    IF p_default_usage_criteria IS NOT NULL AND p_default_usage_criteria <> '' THEN
        BEGIN
            v_usage_criteria := p_default_usage_criteria::JSONB;
        EXCEPTION WHEN OTHERS THEN
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request-settings.invalid-usage-criteria';
        END;
    END IF;

    -- UPSERT
    INSERT INTO bonus.bonus_request_settings (
        bonus_type_code, display_name, rules_content,
        is_requestable,
        eligible_groups, eligible_categories,
        min_group_level, min_category_level,
        cooldown_after_approved_days, cooldown_after_rejected_days,
        max_pending_per_player, max_description_length,
        require_minimum_deposit, min_deposit_amount,
        default_usage_criteria,
        display_order, is_active,
        created_at, updated_at
    ) VALUES (
        p_bonus_type_code, v_display_name, v_rules_content,
        p_is_requestable,
        v_eligible_groups, v_eligible_categories,
        p_min_group_level, p_min_category_level,
        p_cooldown_after_approved, p_cooldown_after_rejected,
        p_max_pending_per_player, p_max_description_length,
        false, NULL,
        v_usage_criteria,
        p_display_order, true,
        NOW(), NOW()
    )
    ON CONFLICT (bonus_type_code) WHERE is_active = true
    DO UPDATE SET
        display_name = EXCLUDED.display_name,
        rules_content = EXCLUDED.rules_content,
        is_requestable = EXCLUDED.is_requestable,
        eligible_groups = EXCLUDED.eligible_groups,
        eligible_categories = EXCLUDED.eligible_categories,
        min_group_level = EXCLUDED.min_group_level,
        min_category_level = EXCLUDED.min_category_level,
        cooldown_after_approved_days = EXCLUDED.cooldown_after_approved_days,
        cooldown_after_rejected_days = EXCLUDED.cooldown_after_rejected_days,
        max_pending_per_player = EXCLUDED.max_pending_per_player,
        max_description_length = EXCLUDED.max_description_length,
        default_usage_criteria = EXCLUDED.default_usage_criteria,
        display_order = EXCLUDED.display_order,
        updated_at = NOW()
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION bonus.bonus_request_setting_upsert IS 'Creates or updates a bonus request setting for a specific bonus type code. Handles JSONB parsing for display_name, rules_content, eligible groups/categories, and usage criteria.';

-- ================================================================
-- BONUS_REQUEST_SETTING_GET: Tekil bonus talep ayarı getir
-- ================================================================
-- Bonus tip koduna göre aktif ayarı döner.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_request_setting_get(VARCHAR);

CREATE OR REPLACE FUNCTION bonus.bonus_request_setting_get(
    p_bonus_type_code VARCHAR(50)
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'id', s.id,
        'bonusTypeCode', s.bonus_type_code,
        'displayName', s.display_name,
        'rulesContent', s.rules_content,
        'isRequestable', s.is_requestable,
        'eligibleGroups', s.eligible_groups,
        'eligibleCategories', s.eligible_categories,
        'minGroupLevel', s.min_group_level,
        'minCategoryLevel', s.min_category_level,
        'cooldownAfterApprovedDays', s.cooldown_after_approved_days,
        'cooldownAfterRejectedDays', s.cooldown_after_rejected_days,
        'maxPendingPerPlayer', s.max_pending_per_player,
        'maxDescriptionLength', s.max_description_length,
        'requireMinimumDeposit', s.require_minimum_deposit,
        'minDepositAmount', s.min_deposit_amount,
        'defaultUsageCriteria', s.default_usage_criteria,
        'displayOrder', s.display_order,
        'createdAt', s.created_at,
        'updatedAt', s.updated_at
    )
    INTO v_result
    FROM bonus.bonus_request_settings s
    WHERE s.bonus_type_code = p_bonus_type_code
      AND s.is_active = true;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.bonus-request-settings.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION bonus.bonus_request_setting_get IS 'Returns a single active bonus request setting by bonus type code.';

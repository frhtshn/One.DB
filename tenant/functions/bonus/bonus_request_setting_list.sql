-- ================================================================
-- BONUS_REQUEST_SETTING_LIST: Bonus talep ayarlarını listele
-- ================================================================
-- Tüm aktif bonus talep ayarlarını display_order sırasıyla döner.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_request_setting_list();

CREATE OR REPLACE FUNCTION bonus.bonus_request_setting_list()
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_items JSONB;
BEGIN
    SELECT COALESCE(jsonb_agg(item ORDER BY s.display_order, s.bonus_type_code), '[]'::JSONB)
    INTO v_items
    FROM bonus.bonus_request_settings s,
    LATERAL (
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
        ) AS item
    ) sub
    WHERE s.is_active = true;

    RETURN v_items;
END;
$$;

COMMENT ON FUNCTION bonus.bonus_request_setting_list IS 'Lists all active bonus request settings ordered by display_order. Returns full configuration for each bonus type.';

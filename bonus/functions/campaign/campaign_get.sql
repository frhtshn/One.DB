-- ================================================================
-- CAMPAIGN_GET: Tekil kampanya detay
-- ================================================================
-- Tüm kampanya bilgileri + bütçe kullanım yüzdesi.
-- ================================================================

DROP FUNCTION IF EXISTS campaign.campaign_get(BIGINT);

CREATE OR REPLACE FUNCTION campaign.campaign_get(
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
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.campaign.id-required';
    END IF;

    SELECT jsonb_build_object(
        'id', c.id,
        'clientId', c.client_id,
        'campaignCode', c.campaign_code,
        'campaignName', c.campaign_name,
        'description', c.description,
        'campaignType', c.campaign_type,
        'bonusRuleIds', c.bonus_rule_ids,
        'startDate', c.start_date,
        'endDate', c.end_date,
        'budgetCurrency', c.budget_currency,
        'totalBudget', c.total_budget,
        'spentBudget', c.spent_budget,
        'budgetUsedPercent', CASE
            WHEN c.total_budget IS NOT NULL AND c.total_budget > 0
            THEN ROUND((c.spent_budget / c.total_budget) * 100, 2)
            ELSE NULL
        END,
        'awardStrategy', c.award_strategy,
        'targetSegments', c.target_segments,
        'status', c.status,
        'createdAt', c.created_at,
        'updatedAt', c.updated_at
    )
    INTO v_result
    FROM campaign.campaigns c
    WHERE c.id = p_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.campaign.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION campaign.campaign_get(BIGINT) IS 'Returns single campaign detail with budget usage percentage.';

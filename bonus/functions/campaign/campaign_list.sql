-- ================================================================
-- CAMPAIGN_LIST: Kampanya listesi
-- ================================================================
-- Filtre: client_id, campaign_type, status.
-- Platform seviyesi kampanyalar (client_id=NULL) dahil.
-- ================================================================

DROP FUNCTION IF EXISTS campaign.campaign_list(BIGINT, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION campaign.campaign_list(
    p_client_id BIGINT DEFAULT NULL,
    p_campaign_type VARCHAR(50) DEFAULT NULL,
    p_status VARCHAR(20) DEFAULT NULL
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
            'id', c.id,
            'clientId', c.client_id,
            'campaignCode', c.campaign_code,
            'campaignName', c.campaign_name,
            'campaignType', c.campaign_type,
            'startDate', c.start_date,
            'endDate', c.end_date,
            'budgetCurrency', c.budget_currency,
            'totalBudget', c.total_budget,
            'spentBudget', c.spent_budget,
            'awardStrategy', c.award_strategy,
            'status', c.status,
            'createdAt', c.created_at
        ) ORDER BY c.start_date DESC
    ), '[]'::jsonb)
    INTO v_result
    FROM campaign.campaigns c
    WHERE (p_client_id IS NULL OR c.client_id IS NULL OR c.client_id = p_client_id)
      AND (p_campaign_type IS NULL OR c.campaign_type = LOWER(TRIM(p_campaign_type)))
      AND (p_status IS NULL OR c.status = p_status);

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION campaign.campaign_list(BIGINT, VARCHAR, VARCHAR) IS 'Lists campaigns filtered by client, type, and status. Includes platform-level campaigns. Ordered by start_date descending.';

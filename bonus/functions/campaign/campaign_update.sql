-- ================================================================
-- CAMPAIGN_UPDATE: Kampanya güncelle
-- ================================================================
-- COALESCE pattern: NULL = mevcut değeri koru.
-- Bütçe ve durum güncellemesi dahil.
-- ================================================================

DROP FUNCTION IF EXISTS bonus.campaign_update(BIGINT, VARCHAR, VARCHAR, TEXT, VARCHAR, TEXT, TIMESTAMPTZ, TIMESTAMPTZ, CHAR, DECIMAL, VARCHAR, TEXT, VARCHAR);

CREATE OR REPLACE FUNCTION campaign.campaign_update(
    p_id BIGINT,
    p_campaign_code VARCHAR(100) DEFAULT NULL,
    p_campaign_name VARCHAR(255) DEFAULT NULL,
    p_description TEXT DEFAULT NULL,
    p_campaign_type VARCHAR(50) DEFAULT NULL,
    p_bonus_rule_ids TEXT DEFAULT NULL,
    p_start_date TIMESTAMPTZ DEFAULT NULL,
    p_end_date TIMESTAMPTZ DEFAULT NULL,
    p_budget_currency CHAR(3) DEFAULT NULL,
    p_total_budget DECIMAL(18,2) DEFAULT NULL,
    p_award_strategy VARCHAR(30) DEFAULT NULL,
    p_target_segments TEXT DEFAULT NULL,
    p_status VARCHAR(20) DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_current RECORD;
BEGIN
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.campaign.id-required';
    END IF;

    SELECT id, client_id, campaign_code INTO v_current
    FROM campaign.campaigns WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.campaign.not-found';
    END IF;

    -- campaign_code değişiyorsa unique kontrolü
    IF p_campaign_code IS NOT NULL AND UPPER(TRIM(p_campaign_code)) != v_current.campaign_code THEN
        IF EXISTS (
            SELECT 1 FROM campaign.campaigns
            WHERE client_id IS NOT DISTINCT FROM v_current.client_id
              AND campaign_code = UPPER(TRIM(p_campaign_code))
              AND id != p_id
        ) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.campaign.code-exists';
        END IF;
    END IF;

    -- status validasyon
    IF p_status IS NOT NULL AND p_status NOT IN ('draft', 'active', 'paused', 'ended') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.campaign.invalid-status';
    END IF;

    -- award_strategy validasyon
    IF p_award_strategy IS NOT NULL AND p_award_strategy NOT IN ('automatic', 'claim', 'manual') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.campaign.invalid-award-strategy';
    END IF;

    UPDATE campaign.campaigns SET
        campaign_code = COALESCE(UPPER(TRIM(NULLIF(p_campaign_code, ''))), campaign_code),
        campaign_name = COALESCE(TRIM(NULLIF(p_campaign_name, '')), campaign_name),
        description = COALESCE(p_description, description),
        campaign_type = COALESCE(LOWER(TRIM(NULLIF(p_campaign_type, ''))), campaign_type),
        bonus_rule_ids = CASE WHEN p_bonus_rule_ids IS NOT NULL THEN p_bonus_rule_ids::JSONB ELSE bonus_rule_ids END,
        start_date = COALESCE(p_start_date, start_date),
        end_date = COALESCE(p_end_date, end_date),
        budget_currency = COALESCE(p_budget_currency, budget_currency),
        total_budget = COALESCE(p_total_budget, total_budget),
        award_strategy = COALESCE(p_award_strategy, award_strategy),
        target_segments = CASE WHEN p_target_segments IS NOT NULL THEN p_target_segments::JSONB ELSE target_segments END,
        status = COALESCE(p_status, status),
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION campaign.campaign_update IS 'Updates a campaign. COALESCE pattern preserves existing values. Supports budget, status, and rule association changes.';

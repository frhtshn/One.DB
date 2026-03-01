-- ================================================================
-- CAMPAIGN_CREATE: Kampanya oluştur
-- ================================================================
-- Bonus kurallarını gruplandıran pazarlama kampanyası.
-- Bütçe takibi ve hedef kitle segmentasyonu destekler.
-- Unique: (client_id, campaign_code).
-- ================================================================

DROP FUNCTION IF EXISTS campaign.campaign_create(BIGINT, VARCHAR, VARCHAR, TEXT, VARCHAR, TEXT, TIMESTAMPTZ, TIMESTAMPTZ, CHAR, DECIMAL, VARCHAR, TEXT);

CREATE OR REPLACE FUNCTION campaign.campaign_create(
    p_client_id BIGINT,
    p_campaign_code VARCHAR(100),
    p_campaign_name VARCHAR(255),
    p_description TEXT DEFAULT NULL,
    p_campaign_type VARCHAR(50) DEFAULT NULL,
    p_bonus_rule_ids TEXT DEFAULT NULL,
    p_start_date TIMESTAMPTZ DEFAULT NULL,
    p_end_date TIMESTAMPTZ DEFAULT NULL,
    p_budget_currency CHAR(3) DEFAULT NULL,
    p_total_budget DECIMAL(18,2) DEFAULT NULL,
    p_award_strategy VARCHAR(30) DEFAULT 'automatic',
    p_target_segments TEXT DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_new_id BIGINT;
BEGIN
    -- Zorunlu alan kontrolleri
    IF p_campaign_code IS NULL OR TRIM(p_campaign_code) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.campaign.code-required';
    END IF;

    IF p_campaign_name IS NULL OR TRIM(p_campaign_name) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.campaign.name-required';
    END IF;

    IF p_campaign_type IS NULL OR TRIM(p_campaign_type) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.campaign.type-required';
    END IF;

    IF p_start_date IS NULL OR p_end_date IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.campaign.dates-required';
    END IF;

    IF p_end_date <= p_start_date THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.campaign.end-before-start';
    END IF;

    -- award_strategy validasyon
    IF p_award_strategy NOT IN ('automatic', 'claim', 'manual') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.campaign.invalid-award-strategy';
    END IF;

    -- Unique kod kontrolü
    IF EXISTS (
        SELECT 1 FROM campaign.campaigns
        WHERE client_id IS NOT DISTINCT FROM p_client_id
          AND campaign_code = UPPER(TRIM(p_campaign_code))
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.campaign.code-exists';
    END IF;

    INSERT INTO campaign.campaigns (
        client_id, campaign_code, campaign_name, description,
        campaign_type, bonus_rule_ids,
        start_date, end_date,
        budget_currency, total_budget, spent_budget,
        award_strategy, target_segments,
        status, created_at, updated_at
    ) VALUES (
        p_client_id,
        UPPER(TRIM(p_campaign_code)),
        TRIM(p_campaign_name),
        p_description,
        LOWER(TRIM(p_campaign_type)),
        CASE WHEN p_bonus_rule_ids IS NOT NULL THEN p_bonus_rule_ids::JSONB ELSE NULL END,
        p_start_date,
        p_end_date,
        p_budget_currency,
        p_total_budget,
        0,
        p_award_strategy,
        CASE WHEN p_target_segments IS NOT NULL THEN p_target_segments::JSONB ELSE NULL END,
        'draft',
        NOW(), NOW()
    )
    RETURNING id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION campaign.campaign_create IS 'Creates a marketing campaign with bonus rule associations, budget tracking, and audience segmentation. Starts in draft status. Unique by (client_id, campaign_code).';

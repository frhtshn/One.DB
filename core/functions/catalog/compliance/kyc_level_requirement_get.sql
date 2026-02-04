-- ================================================================
-- KYC_LEVEL_REQUIREMENT_GET: Tekil seviye gereksinimi getirir
-- Platform Admin (SuperAdmin + Admin) erişebilir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.kyc_level_requirement_get(BIGINT, INT);

CREATE OR REPLACE FUNCTION catalog.kyc_level_requirement_get(
    p_caller_id BIGINT,
    p_id INT
)
RETURNS TABLE(
    id INT,
    jurisdiction_id INT,
    jurisdiction_code VARCHAR(20),
    jurisdiction_name VARCHAR(100),
    kyc_level VARCHAR(20),
    level_order INT,
    trigger_cumulative_deposit DECIMAL(18,2),
    trigger_cumulative_withdrawal DECIMAL(18,2),
    trigger_single_deposit DECIMAL(18,2),
    trigger_single_withdrawal DECIMAL(18,2),
    trigger_balance_threshold DECIMAL(18,2),
    trigger_threshold_currency CHAR(3),
    trigger_days_since_registration INT,
    trigger_on_first_withdrawal BOOLEAN,
    max_single_deposit DECIMAL(18,2),
    max_single_withdrawal DECIMAL(18,2),
    max_daily_deposit DECIMAL(18,2),
    max_daily_withdrawal DECIMAL(18,2),
    max_monthly_deposit DECIMAL(18,2),
    max_monthly_withdrawal DECIMAL(18,2),
    limit_currency CHAR(3),
    required_documents JSONB,
    required_verifications JSONB,
    verification_deadline_hours INT,
    grace_period_hours INT,
    on_deadline_action VARCHAR(30),
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    -- Platform Admin check
    PERFORM security.user_assert_platform_admin(p_caller_id);

    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-level-requirement.id-required';
    END IF;

    RETURN QUERY
    SELECT
        klr.id,
        klr.jurisdiction_id,
        j.code AS jurisdiction_code,
        j.name AS jurisdiction_name,
        klr.kyc_level,
        klr.level_order,
        klr.trigger_cumulative_deposit,
        klr.trigger_cumulative_withdrawal,
        klr.trigger_single_deposit,
        klr.trigger_single_withdrawal,
        klr.trigger_balance_threshold,
        klr.trigger_threshold_currency,
        klr.trigger_days_since_registration,
        klr.trigger_on_first_withdrawal,
        klr.max_single_deposit,
        klr.max_single_withdrawal,
        klr.max_daily_deposit,
        klr.max_daily_withdrawal,
        klr.max_monthly_deposit,
        klr.max_monthly_withdrawal,
        klr.limit_currency,
        klr.required_documents,
        klr.required_verifications,
        klr.verification_deadline_hours,
        klr.grace_period_hours,
        klr.on_deadline_action,
        klr.is_active,
        klr.created_at,
        klr.updated_at
    FROM catalog.kyc_level_requirements klr
    JOIN catalog.jurisdictions j ON j.id = klr.jurisdiction_id
    WHERE klr.id = p_id;

    -- Bulunamadı kontrolü
    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-level-requirement.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION catalog.kyc_level_requirement_get IS 'Gets a single KYC level requirement by ID. Platform Admin only.';

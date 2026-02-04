-- ================================================================
-- KYC_POLICY_GET: Tekil KYC policy getirir
-- Platform Admin (SuperAdmin + Admin) erişebilir
-- ID veya jurisdiction_id ile aranabilir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.kyc_policy_get(BIGINT, INT);

CREATE OR REPLACE FUNCTION catalog.kyc_policy_get(
    p_caller_id BIGINT,
    p_id INT
)
RETURNS TABLE(
    id INT,
    jurisdiction_id INT,
    jurisdiction_code VARCHAR(20),
    jurisdiction_name VARCHAR(100),
    verification_timing VARCHAR(30),
    verification_deadline_hours INT,
    grace_period_hours INT,
    edd_deposit_threshold DECIMAL(18,2),
    edd_withdrawal_threshold DECIMAL(18,2),
    edd_cumulative_threshold DECIMAL(18,2),
    edd_threshold_currency CHAR(3),
    min_age INT,
    age_verification_required BOOLEAN,
    address_verification_required BOOLEAN,
    address_document_max_age_days INT,
    sof_threshold DECIMAL(18,2),
    sof_required_above_threshold BOOLEAN,
    pep_screening_required BOOLEAN,
    sanctions_screening_required BOOLEAN,
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
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-policy.id-required';
    END IF;

    RETURN QUERY
    SELECT
        kp.id,
        kp.jurisdiction_id,
        j.code AS jurisdiction_code,
        j.name AS jurisdiction_name,
        kp.verification_timing,
        kp.verification_deadline_hours,
        kp.grace_period_hours,
        kp.edd_deposit_threshold,
        kp.edd_withdrawal_threshold,
        kp.edd_cumulative_threshold,
        kp.edd_threshold_currency,
        kp.min_age,
        kp.age_verification_required,
        kp.address_verification_required,
        kp.address_document_max_age_days,
        kp.sof_threshold,
        kp.sof_required_above_threshold,
        kp.pep_screening_required,
        kp.sanctions_screening_required,
        kp.is_active,
        kp.created_at,
        kp.updated_at
    FROM catalog.kyc_policies kp
    JOIN catalog.jurisdictions j ON j.id = kp.jurisdiction_id
    WHERE kp.id = p_id;

    -- Bulunamadı kontrolü
    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-policy.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION catalog.kyc_policy_get IS 'Gets a single KYC policy by ID. Platform Admin only.';

-- ================================================================
-- KYC_POLICY_UPDATE: KYC policy günceller
-- Platform Admin (SuperAdmin + Admin) kullanabilir
-- NULL geçilen alanlar güncellenmez (COALESCE pattern)
-- ================================================================

DROP FUNCTION IF EXISTS catalog.kyc_policy_update(
    BIGINT, INT, VARCHAR, INT, INT,
    DECIMAL, DECIMAL, DECIMAL, CHAR,
    INT, BOOLEAN, BOOLEAN, INT,
    DECIMAL, BOOLEAN, BOOLEAN, BOOLEAN, BOOLEAN
);

CREATE OR REPLACE FUNCTION catalog.kyc_policy_update(
    p_caller_id BIGINT,
    p_id INT,
    p_verification_timing VARCHAR(30) DEFAULT NULL,
    p_verification_deadline_hours INT DEFAULT NULL,
    p_grace_period_hours INT DEFAULT NULL,
    p_edd_deposit_threshold DECIMAL(18,2) DEFAULT NULL,
    p_edd_withdrawal_threshold DECIMAL(18,2) DEFAULT NULL,
    p_edd_cumulative_threshold DECIMAL(18,2) DEFAULT NULL,
    p_edd_threshold_currency CHAR(3) DEFAULT NULL,
    p_min_age INT DEFAULT NULL,
    p_age_verification_required BOOLEAN DEFAULT NULL,
    p_address_verification_required BOOLEAN DEFAULT NULL,
    p_address_document_max_age_days INT DEFAULT NULL,
    p_sof_threshold DECIMAL(18,2) DEFAULT NULL,
    p_sof_required_above_threshold BOOLEAN DEFAULT NULL,
    p_pep_screening_required BOOLEAN DEFAULT NULL,
    p_sanctions_screening_required BOOLEAN DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Platform Admin check
    PERFORM security.user_assert_platform_admin(p_caller_id);

    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-policy.id-required';
    END IF;

    -- Mevcut kayıt kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.kyc_policies kp WHERE kp.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-policy.not-found';
    END IF;

    -- Verification timing validasyonu
    IF p_verification_timing IS NOT NULL AND p_verification_timing NOT IN (
        'before_registration', 'before_deposit', 'after_registration', 'before_withdrawal'
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-policy.verification-timing-invalid';
    END IF;

    -- Min age validasyonu
    IF p_min_age IS NOT NULL AND p_min_age < 18 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-policy.min-age-invalid';
    END IF;

    -- Güncelle
    UPDATE catalog.kyc_policies SET
        verification_timing = COALESCE(p_verification_timing, verification_timing),
        verification_deadline_hours = COALESCE(p_verification_deadline_hours, verification_deadline_hours),
        grace_period_hours = COALESCE(p_grace_period_hours, grace_period_hours),
        edd_deposit_threshold = COALESCE(p_edd_deposit_threshold, edd_deposit_threshold),
        edd_withdrawal_threshold = COALESCE(p_edd_withdrawal_threshold, edd_withdrawal_threshold),
        edd_cumulative_threshold = COALESCE(p_edd_cumulative_threshold, edd_cumulative_threshold),
        edd_threshold_currency = COALESCE(p_edd_threshold_currency, edd_threshold_currency),
        min_age = COALESCE(p_min_age, min_age),
        age_verification_required = COALESCE(p_age_verification_required, age_verification_required),
        address_verification_required = COALESCE(p_address_verification_required, address_verification_required),
        address_document_max_age_days = COALESCE(p_address_document_max_age_days, address_document_max_age_days),
        sof_threshold = COALESCE(p_sof_threshold, sof_threshold),
        sof_required_above_threshold = COALESCE(p_sof_required_above_threshold, sof_required_above_threshold),
        pep_screening_required = COALESCE(p_pep_screening_required, pep_screening_required),
        sanctions_screening_required = COALESCE(p_sanctions_screening_required, sanctions_screening_required),
        is_active = COALESCE(p_is_active, is_active),
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.kyc_policy_update IS 'Updates a KYC policy. Platform Admin only. NULL values keep existing data.';

-- ================================================================
-- KYC_POLICY_CREATE: Yeni KYC policy oluşturur
-- Her jurisdiction için sadece 1 policy olabilir (1:1)
-- ================================================================

DROP FUNCTION IF EXISTS catalog.kyc_policy_create(
    INT, VARCHAR, INT, INT,
    DECIMAL, DECIMAL, DECIMAL, CHAR,
    INT, BOOLEAN, BOOLEAN, INT,
    DECIMAL, BOOLEAN, BOOLEAN, BOOLEAN
);

CREATE OR REPLACE FUNCTION catalog.kyc_policy_create(
    p_jurisdiction_id INT,
    p_verification_timing VARCHAR(30),
    p_verification_deadline_hours INT DEFAULT NULL,
    p_grace_period_hours INT DEFAULT 0,
    p_edd_deposit_threshold DECIMAL(18,2) DEFAULT NULL,
    p_edd_withdrawal_threshold DECIMAL(18,2) DEFAULT NULL,
    p_edd_cumulative_threshold DECIMAL(18,2) DEFAULT NULL,
    p_edd_threshold_currency CHAR(3) DEFAULT 'EUR',
    p_min_age INT DEFAULT 18,
    p_age_verification_required BOOLEAN DEFAULT TRUE,
    p_address_verification_required BOOLEAN DEFAULT TRUE,
    p_address_document_max_age_days INT DEFAULT 90,
    p_sof_threshold DECIMAL(18,2) DEFAULT NULL,
    p_sof_required_above_threshold BOOLEAN DEFAULT FALSE,
    p_pep_screening_required BOOLEAN DEFAULT TRUE,
    p_sanctions_screening_required BOOLEAN DEFAULT TRUE
)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_new_id INT;
BEGIN
    -- Jurisdiction kontrolü
    IF p_jurisdiction_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-policy.jurisdiction-required';
    END IF;

    -- Jurisdiction varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.jurisdictions j WHERE j.id = p_jurisdiction_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.jurisdiction.not-found';
    END IF;

    -- Mevcut policy kontrolü (1:1 ilişki)
    IF EXISTS(SELECT 1 FROM catalog.kyc_policies kp WHERE kp.jurisdiction_id = p_jurisdiction_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.kyc-policy.already-exists-for-jurisdiction';
    END IF;

    -- Verification timing kontrolü
    IF p_verification_timing IS NULL OR p_verification_timing NOT IN (
        'before_registration', 'before_deposit', 'after_registration', 'before_withdrawal'
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-policy.verification-timing-invalid';
    END IF;

    -- Min age kontrolü
    IF p_min_age IS NOT NULL AND p_min_age < 18 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-policy.min-age-invalid';
    END IF;

    -- Ekle
    INSERT INTO catalog.kyc_policies (
        jurisdiction_id,
        verification_timing,
        verification_deadline_hours,
        grace_period_hours,
        edd_deposit_threshold,
        edd_withdrawal_threshold,
        edd_cumulative_threshold,
        edd_threshold_currency,
        min_age,
        age_verification_required,
        address_verification_required,
        address_document_max_age_days,
        sof_threshold,
        sof_required_above_threshold,
        pep_screening_required,
        sanctions_screening_required,
        is_active,
        created_at,
        updated_at
    )
    VALUES (
        p_jurisdiction_id,
        p_verification_timing,
        p_verification_deadline_hours,
        COALESCE(p_grace_period_hours, 0),
        p_edd_deposit_threshold,
        p_edd_withdrawal_threshold,
        p_edd_cumulative_threshold,
        COALESCE(p_edd_threshold_currency, 'EUR'),
        COALESCE(p_min_age, 18),
        COALESCE(p_age_verification_required, TRUE),
        COALESCE(p_address_verification_required, TRUE),
        COALESCE(p_address_document_max_age_days, 90),
        p_sof_threshold,
        COALESCE(p_sof_required_above_threshold, FALSE),
        COALESCE(p_pep_screening_required, TRUE),
        COALESCE(p_sanctions_screening_required, TRUE),
        TRUE,
        NOW(),
        NOW()
    )
    RETURNING catalog.kyc_policies.id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION catalog.kyc_policy_create IS 'Creates a KYC policy for a jurisdiction. One policy per jurisdiction.';

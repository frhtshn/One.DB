-- ================================================================
-- KYC_LEVEL_REQUIREMENT_CREATE: Yeni seviye gereksinimi oluşturur
-- Platform Admin (SuperAdmin + Admin) kullanabilir
-- Her jurisdiction için her level sadece 1 kayıt olabilir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.kyc_level_requirement_create(
    BIGINT, INT, VARCHAR, INT,
    DECIMAL, DECIMAL, DECIMAL, DECIMAL, DECIMAL, CHAR, INT, BOOLEAN,
    DECIMAL, DECIMAL, DECIMAL, DECIMAL, DECIMAL, DECIMAL, CHAR,
    JSONB, JSONB, INT, INT, VARCHAR
);
DROP FUNCTION IF EXISTS catalog.kyc_level_requirement_create(
    BIGINT, INT, VARCHAR, INT,
    DECIMAL, DECIMAL, DECIMAL, DECIMAL, DECIMAL, CHAR, INT, BOOLEAN,
    DECIMAL, DECIMAL, DECIMAL, DECIMAL, DECIMAL, DECIMAL, CHAR,
    TEXT, TEXT, INT, INT, VARCHAR
);

CREATE OR REPLACE FUNCTION catalog.kyc_level_requirement_create(
    p_caller_id BIGINT,
    p_jurisdiction_id INT,
    p_kyc_level VARCHAR(20),
    p_level_order INT,
    -- Tetikleyiciler
    p_trigger_cumulative_deposit DECIMAL(18,2) DEFAULT NULL,
    p_trigger_cumulative_withdrawal DECIMAL(18,2) DEFAULT NULL,
    p_trigger_single_deposit DECIMAL(18,2) DEFAULT NULL,
    p_trigger_single_withdrawal DECIMAL(18,2) DEFAULT NULL,
    p_trigger_balance_threshold DECIMAL(18,2) DEFAULT NULL,
    p_trigger_threshold_currency CHAR(3) DEFAULT 'EUR',
    p_trigger_days_since_registration INT DEFAULT NULL,
    p_trigger_on_first_withdrawal BOOLEAN DEFAULT FALSE,
    -- Limitler
    p_max_single_deposit DECIMAL(18,2) DEFAULT NULL,
    p_max_single_withdrawal DECIMAL(18,2) DEFAULT NULL,
    p_max_daily_deposit DECIMAL(18,2) DEFAULT NULL,
    p_max_daily_withdrawal DECIMAL(18,2) DEFAULT NULL,
    p_max_monthly_deposit DECIMAL(18,2) DEFAULT NULL,
    p_max_monthly_withdrawal DECIMAL(18,2) DEFAULT NULL,
    p_limit_currency CHAR(3) DEFAULT 'EUR',
    -- Gereksinimler
    p_required_documents TEXT DEFAULT NULL,
    p_required_verifications TEXT DEFAULT NULL,
    p_verification_deadline_hours INT DEFAULT NULL,
    p_grace_period_hours INT DEFAULT 0,
    p_on_deadline_action VARCHAR(30) DEFAULT 'block_deposits'
)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_new_id INT;
BEGIN
    -- Platform Admin check
    PERFORM security.user_assert_platform_admin(p_caller_id);

    -- Jurisdiction kontrolü
    IF p_jurisdiction_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-level-requirement.jurisdiction-required';
    END IF;

    -- Jurisdiction varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.jurisdictions j WHERE j.id = p_jurisdiction_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.jurisdiction.not-found';
    END IF;

    -- KYC level kontrolü
    IF p_kyc_level IS NULL OR p_kyc_level NOT IN ('basic', 'standard', 'enhanced') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-level-requirement.level-invalid';
    END IF;

    -- Level order kontrolü
    IF p_level_order IS NULL OR p_level_order < 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-level-requirement.level-order-invalid';
    END IF;

    -- On deadline action kontrolü
    IF p_on_deadline_action IS NOT NULL AND p_on_deadline_action NOT IN (
        'block_deposits', 'block_withdrawals', 'block_all', 'suspend_account'
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-level-requirement.deadline-action-invalid';
    END IF;

    -- Duplicate kontrolü (jurisdiction + kyc_level unique)
    IF EXISTS(
        SELECT 1 FROM catalog.kyc_level_requirements klr
        WHERE klr.jurisdiction_id = p_jurisdiction_id AND klr.kyc_level = p_kyc_level
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.kyc-level-requirement.already-exists';
    END IF;

    -- Ekle
    INSERT INTO catalog.kyc_level_requirements (
        jurisdiction_id, kyc_level, level_order,
        trigger_cumulative_deposit, trigger_cumulative_withdrawal,
        trigger_single_deposit, trigger_single_withdrawal,
        trigger_balance_threshold, trigger_threshold_currency,
        trigger_days_since_registration, trigger_on_first_withdrawal,
        max_single_deposit, max_single_withdrawal,
        max_daily_deposit, max_daily_withdrawal,
        max_monthly_deposit, max_monthly_withdrawal, limit_currency,
        required_documents, required_verifications,
        verification_deadline_hours, grace_period_hours, on_deadline_action,
        is_active, created_at, updated_at
    )
    VALUES (
        p_jurisdiction_id, p_kyc_level, p_level_order,
        p_trigger_cumulative_deposit, p_trigger_cumulative_withdrawal,
        p_trigger_single_deposit, p_trigger_single_withdrawal,
        p_trigger_balance_threshold, COALESCE(p_trigger_threshold_currency, 'EUR'),
        p_trigger_days_since_registration, COALESCE(p_trigger_on_first_withdrawal, FALSE),
        p_max_single_deposit, p_max_single_withdrawal,
        p_max_daily_deposit, p_max_daily_withdrawal,
        p_max_monthly_deposit, p_max_monthly_withdrawal, COALESCE(p_limit_currency, 'EUR'),
        p_required_documents::jsonb, p_required_verifications::jsonb,
        p_verification_deadline_hours, COALESCE(p_grace_period_hours, 0),
        COALESCE(p_on_deadline_action, 'block_deposits'),
        TRUE, NOW(), NOW()
    )
    RETURNING catalog.kyc_level_requirements.id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION catalog.kyc_level_requirement_create IS 'Creates a KYC level requirement. Platform Admin only. One per jurisdiction+level.';

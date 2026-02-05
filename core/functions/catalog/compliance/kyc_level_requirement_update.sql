-- ================================================================
-- KYC_LEVEL_REQUIREMENT_UPDATE: Seviye gereksinimi günceller
-- NULL geçilen alanlar güncellenmez (COALESCE pattern)
-- ================================================================

DROP FUNCTION IF EXISTS catalog.kyc_level_requirement_update(
    INT, VARCHAR, INT,
    DECIMAL, DECIMAL, DECIMAL, DECIMAL, DECIMAL, CHAR, INT, BOOLEAN,
    DECIMAL, DECIMAL, DECIMAL, DECIMAL, DECIMAL, DECIMAL, CHAR,
    JSONB, JSONB, INT, INT, VARCHAR, BOOLEAN
);
DROP FUNCTION IF EXISTS catalog.kyc_level_requirement_update(
    INT, VARCHAR, INT,
    DECIMAL, DECIMAL, DECIMAL, DECIMAL, DECIMAL, CHAR, INT, BOOLEAN,
    DECIMAL, DECIMAL, DECIMAL, DECIMAL, DECIMAL, DECIMAL, CHAR,
    TEXT, TEXT, INT, INT, VARCHAR, BOOLEAN
);

CREATE OR REPLACE FUNCTION catalog.kyc_level_requirement_update(
    p_id INT,
    p_kyc_level VARCHAR(20) DEFAULT NULL,
    p_level_order INT DEFAULT NULL,
    -- Tetikleyiciler
    p_trigger_cumulative_deposit DECIMAL(18,2) DEFAULT NULL,
    p_trigger_cumulative_withdrawal DECIMAL(18,2) DEFAULT NULL,
    p_trigger_single_deposit DECIMAL(18,2) DEFAULT NULL,
    p_trigger_single_withdrawal DECIMAL(18,2) DEFAULT NULL,
    p_trigger_balance_threshold DECIMAL(18,2) DEFAULT NULL,
    p_trigger_threshold_currency CHAR(3) DEFAULT NULL,
    p_trigger_days_since_registration INT DEFAULT NULL,
    p_trigger_on_first_withdrawal BOOLEAN DEFAULT NULL,
    -- Limitler
    p_max_single_deposit DECIMAL(18,2) DEFAULT NULL,
    p_max_single_withdrawal DECIMAL(18,2) DEFAULT NULL,
    p_max_daily_deposit DECIMAL(18,2) DEFAULT NULL,
    p_max_daily_withdrawal DECIMAL(18,2) DEFAULT NULL,
    p_max_monthly_deposit DECIMAL(18,2) DEFAULT NULL,
    p_max_monthly_withdrawal DECIMAL(18,2) DEFAULT NULL,
    p_limit_currency CHAR(3) DEFAULT NULL,
    -- Gereksinimler
    p_required_documents TEXT DEFAULT NULL,
    p_required_verifications TEXT DEFAULT NULL,
    p_verification_deadline_hours INT DEFAULT NULL,
    p_grace_period_hours INT DEFAULT NULL,
    p_on_deadline_action VARCHAR(30) DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_jurisdiction_id INT;
    v_existing_id INT;
BEGIN
    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-level-requirement.id-required';
    END IF;

    -- Mevcut kayıt kontrolü ve jurisdiction_id al
    SELECT klr.jurisdiction_id INTO v_jurisdiction_id
    FROM catalog.kyc_level_requirements klr
    WHERE klr.id = p_id;

    IF v_jurisdiction_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-level-requirement.not-found';
    END IF;

    -- KYC level validasyonu
    IF p_kyc_level IS NOT NULL AND p_kyc_level NOT IN ('basic', 'standard', 'enhanced') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-level-requirement.level-invalid';
    END IF;

    -- Level değişiyorsa duplicate kontrolü
    IF p_kyc_level IS NOT NULL THEN
        SELECT klr.id INTO v_existing_id
        FROM catalog.kyc_level_requirements klr
        WHERE klr.jurisdiction_id = v_jurisdiction_id
          AND klr.kyc_level = p_kyc_level
          AND klr.id != p_id;

        IF v_existing_id IS NOT NULL THEN
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.kyc-level-requirement.already-exists';
        END IF;
    END IF;

    -- On deadline action validasyonu
    IF p_on_deadline_action IS NOT NULL AND p_on_deadline_action NOT IN (
        'block_deposits', 'block_withdrawals', 'block_all', 'suspend_account'
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-level-requirement.deadline-action-invalid';
    END IF;

    -- Güncelle
    UPDATE catalog.kyc_level_requirements SET
        kyc_level = COALESCE(p_kyc_level, kyc_level),
        level_order = COALESCE(p_level_order, level_order),
        trigger_cumulative_deposit = COALESCE(p_trigger_cumulative_deposit, trigger_cumulative_deposit),
        trigger_cumulative_withdrawal = COALESCE(p_trigger_cumulative_withdrawal, trigger_cumulative_withdrawal),
        trigger_single_deposit = COALESCE(p_trigger_single_deposit, trigger_single_deposit),
        trigger_single_withdrawal = COALESCE(p_trigger_single_withdrawal, trigger_single_withdrawal),
        trigger_balance_threshold = COALESCE(p_trigger_balance_threshold, trigger_balance_threshold),
        trigger_threshold_currency = COALESCE(p_trigger_threshold_currency, trigger_threshold_currency),
        trigger_days_since_registration = COALESCE(p_trigger_days_since_registration, trigger_days_since_registration),
        trigger_on_first_withdrawal = COALESCE(p_trigger_on_first_withdrawal, trigger_on_first_withdrawal),
        max_single_deposit = COALESCE(p_max_single_deposit, max_single_deposit),
        max_single_withdrawal = COALESCE(p_max_single_withdrawal, max_single_withdrawal),
        max_daily_deposit = COALESCE(p_max_daily_deposit, max_daily_deposit),
        max_daily_withdrawal = COALESCE(p_max_daily_withdrawal, max_daily_withdrawal),
        max_monthly_deposit = COALESCE(p_max_monthly_deposit, max_monthly_deposit),
        max_monthly_withdrawal = COALESCE(p_max_monthly_withdrawal, max_monthly_withdrawal),
        limit_currency = COALESCE(p_limit_currency, limit_currency),
        required_documents = COALESCE(p_required_documents::jsonb, required_documents),
        required_verifications = COALESCE(p_required_verifications::jsonb, required_verifications),
        verification_deadline_hours = COALESCE(p_verification_deadline_hours, verification_deadline_hours),
        grace_period_hours = COALESCE(p_grace_period_hours, grace_period_hours),
        on_deadline_action = COALESCE(p_on_deadline_action, on_deadline_action),
        is_active = COALESCE(p_is_active, is_active),
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.kyc_level_requirement_update IS 'Updates a KYC level requirement.';

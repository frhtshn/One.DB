-- ================================================================
-- RESPONSIBLE_GAMING_POLICY_LIST: Sorumlu oyun politikalarını listeler
-- Jurisdiction bazlı filtreleme
-- ================================================================

DROP FUNCTION IF EXISTS catalog.responsible_gaming_policy_list(INT, BOOLEAN);

CREATE OR REPLACE FUNCTION catalog.responsible_gaming_policy_list(
    p_jurisdiction_id INT DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS TABLE(
    id INT,
    jurisdiction_id INT,
    jurisdiction_code VARCHAR(20),
    jurisdiction_name VARCHAR(100),
    deposit_limit_required BOOLEAN,
    deposit_limit_options JSONB,
    deposit_limit_max_increase_wait_hours INT,
    loss_limit_required BOOLEAN,
    loss_limit_options JSONB,
    session_limit_required BOOLEAN,
    session_limit_max_hours INT,
    session_break_required BOOLEAN,
    session_break_after_hours INT,
    session_break_duration_minutes INT,
    reality_check_required BOOLEAN,
    reality_check_interval_minutes INT,
    cooling_off_available BOOLEAN,
    cooling_off_min_days INT,
    cooling_off_max_days INT,
    cooling_off_revocable BOOLEAN,
    self_exclusion_available BOOLEAN,
    self_exclusion_min_months INT,
    self_exclusion_permanent_option BOOLEAN,
    self_exclusion_revocable BOOLEAN,
    central_exclusion_system VARCHAR(50),
    central_exclusion_integration_required BOOLEAN,
    central_exclusion_api_endpoint VARCHAR(255),
    anonymous_payments_allowed BOOLEAN,
    crypto_payments_allowed BOOLEAN,
    credit_card_gambling_allowed BOOLEAN,
    payment_method_ownership_verification BOOLEAN,
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        rgp.id,
        rgp.jurisdiction_id,
        j.code AS jurisdiction_code,
        j.name AS jurisdiction_name,
        rgp.deposit_limit_required,
        rgp.deposit_limit_options,
        rgp.deposit_limit_max_increase_wait_hours,
        rgp.loss_limit_required,
        rgp.loss_limit_options,
        rgp.session_limit_required,
        rgp.session_limit_max_hours,
        rgp.session_break_required,
        rgp.session_break_after_hours,
        rgp.session_break_duration_minutes,
        rgp.reality_check_required,
        rgp.reality_check_interval_minutes,
        rgp.cooling_off_available,
        rgp.cooling_off_min_days,
        rgp.cooling_off_max_days,
        rgp.cooling_off_revocable,
        rgp.self_exclusion_available,
        rgp.self_exclusion_min_months,
        rgp.self_exclusion_permanent_option,
        rgp.self_exclusion_revocable,
        rgp.central_exclusion_system,
        rgp.central_exclusion_integration_required,
        rgp.central_exclusion_api_endpoint,
        rgp.anonymous_payments_allowed,
        rgp.crypto_payments_allowed,
        rgp.credit_card_gambling_allowed,
        rgp.payment_method_ownership_verification,
        rgp.is_active,
        rgp.created_at,
        rgp.updated_at
    FROM catalog.responsible_gaming_policies rgp
    JOIN catalog.jurisdictions j ON j.id = rgp.jurisdiction_id
    WHERE (p_jurisdiction_id IS NULL OR rgp.jurisdiction_id = p_jurisdiction_id)
      AND (p_is_active IS NULL OR rgp.is_active = p_is_active)
    ORDER BY j.name;
END;
$$;

COMMENT ON FUNCTION catalog.responsible_gaming_policy_list IS 'Lists responsible gaming policies.';

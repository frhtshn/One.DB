-- ================================================================
-- RESPONSIBLE_GAMING_POLICY_UPDATE: Sorumlu oyun politikası günceller
-- Platform Admin (SuperAdmin + Admin) kullanabilir
-- NULL geçilen alanlar güncellenmez (COALESCE pattern)
-- ================================================================

DROP FUNCTION IF EXISTS catalog.responsible_gaming_policy_update(
    BIGINT, INT,
    BOOLEAN, JSONB, INT,
    BOOLEAN, JSONB,
    BOOLEAN, INT, BOOLEAN, INT, INT,
    BOOLEAN, INT,
    BOOLEAN, INT, INT, BOOLEAN,
    BOOLEAN, INT, BOOLEAN, BOOLEAN,
    VARCHAR, BOOLEAN, VARCHAR,
    BOOLEAN, BOOLEAN, BOOLEAN, BOOLEAN, BOOLEAN
);
DROP FUNCTION IF EXISTS catalog.responsible_gaming_policy_update(
    BIGINT, INT,
    BOOLEAN, TEXT, INT,
    BOOLEAN, TEXT,
    BOOLEAN, INT, BOOLEAN, INT, INT,
    BOOLEAN, INT,
    BOOLEAN, INT, INT, BOOLEAN,
    BOOLEAN, INT, BOOLEAN, BOOLEAN,
    VARCHAR, BOOLEAN, VARCHAR,
    BOOLEAN, BOOLEAN, BOOLEAN, BOOLEAN, BOOLEAN
);

CREATE OR REPLACE FUNCTION catalog.responsible_gaming_policy_update(
    p_caller_id BIGINT,
    p_id INT,
    -- Deposit limits
    p_deposit_limit_required BOOLEAN DEFAULT NULL,
    p_deposit_limit_options TEXT DEFAULT NULL,
    p_deposit_limit_max_increase_wait_hours INT DEFAULT NULL,
    -- Loss limits
    p_loss_limit_required BOOLEAN DEFAULT NULL,
    p_loss_limit_options TEXT DEFAULT NULL,
    -- Session limits
    p_session_limit_required BOOLEAN DEFAULT NULL,
    p_session_limit_max_hours INT DEFAULT NULL,
    p_session_break_required BOOLEAN DEFAULT NULL,
    p_session_break_after_hours INT DEFAULT NULL,
    p_session_break_duration_minutes INT DEFAULT NULL,
    -- Reality check
    p_reality_check_required BOOLEAN DEFAULT NULL,
    p_reality_check_interval_minutes INT DEFAULT NULL,
    -- Cooling off
    p_cooling_off_available BOOLEAN DEFAULT NULL,
    p_cooling_off_min_days INT DEFAULT NULL,
    p_cooling_off_max_days INT DEFAULT NULL,
    p_cooling_off_revocable BOOLEAN DEFAULT NULL,
    -- Self exclusion
    p_self_exclusion_available BOOLEAN DEFAULT NULL,
    p_self_exclusion_min_months INT DEFAULT NULL,
    p_self_exclusion_permanent_option BOOLEAN DEFAULT NULL,
    p_self_exclusion_revocable BOOLEAN DEFAULT NULL,
    -- Central exclusion
    p_central_exclusion_system VARCHAR(50) DEFAULT NULL,
    p_central_exclusion_integration_required BOOLEAN DEFAULT NULL,
    p_central_exclusion_api_endpoint VARCHAR(255) DEFAULT NULL,
    -- Payment restrictions
    p_anonymous_payments_allowed BOOLEAN DEFAULT NULL,
    p_crypto_payments_allowed BOOLEAN DEFAULT NULL,
    p_credit_card_gambling_allowed BOOLEAN DEFAULT NULL,
    p_payment_method_ownership_verification BOOLEAN DEFAULT NULL,
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
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.responsible-gaming-policy.id-required';
    END IF;

    -- Mevcut kayıt kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.responsible_gaming_policies rgp WHERE rgp.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.responsible-gaming-policy.not-found';
    END IF;

    -- Güncelle
    UPDATE catalog.responsible_gaming_policies SET
        deposit_limit_required = COALESCE(p_deposit_limit_required, deposit_limit_required),
        deposit_limit_options = COALESCE(p_deposit_limit_options::jsonb, deposit_limit_options),
        deposit_limit_max_increase_wait_hours = COALESCE(p_deposit_limit_max_increase_wait_hours, deposit_limit_max_increase_wait_hours),
        loss_limit_required = COALESCE(p_loss_limit_required, loss_limit_required),
        loss_limit_options = COALESCE(p_loss_limit_options::jsonb, loss_limit_options),
        session_limit_required = COALESCE(p_session_limit_required, session_limit_required),
        session_limit_max_hours = COALESCE(p_session_limit_max_hours, session_limit_max_hours),
        session_break_required = COALESCE(p_session_break_required, session_break_required),
        session_break_after_hours = COALESCE(p_session_break_after_hours, session_break_after_hours),
        session_break_duration_minutes = COALESCE(p_session_break_duration_minutes, session_break_duration_minutes),
        reality_check_required = COALESCE(p_reality_check_required, reality_check_required),
        reality_check_interval_minutes = COALESCE(p_reality_check_interval_minutes, reality_check_interval_minutes),
        cooling_off_available = COALESCE(p_cooling_off_available, cooling_off_available),
        cooling_off_min_days = COALESCE(p_cooling_off_min_days, cooling_off_min_days),
        cooling_off_max_days = COALESCE(p_cooling_off_max_days, cooling_off_max_days),
        cooling_off_revocable = COALESCE(p_cooling_off_revocable, cooling_off_revocable),
        self_exclusion_available = COALESCE(p_self_exclusion_available, self_exclusion_available),
        self_exclusion_min_months = COALESCE(p_self_exclusion_min_months, self_exclusion_min_months),
        self_exclusion_permanent_option = COALESCE(p_self_exclusion_permanent_option, self_exclusion_permanent_option),
        self_exclusion_revocable = COALESCE(p_self_exclusion_revocable, self_exclusion_revocable),
        central_exclusion_system = COALESCE(p_central_exclusion_system, central_exclusion_system),
        central_exclusion_integration_required = COALESCE(p_central_exclusion_integration_required, central_exclusion_integration_required),
        central_exclusion_api_endpoint = COALESCE(p_central_exclusion_api_endpoint, central_exclusion_api_endpoint),
        anonymous_payments_allowed = COALESCE(p_anonymous_payments_allowed, anonymous_payments_allowed),
        crypto_payments_allowed = COALESCE(p_crypto_payments_allowed, crypto_payments_allowed),
        credit_card_gambling_allowed = COALESCE(p_credit_card_gambling_allowed, credit_card_gambling_allowed),
        payment_method_ownership_verification = COALESCE(p_payment_method_ownership_verification, payment_method_ownership_verification),
        is_active = COALESCE(p_is_active, is_active),
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.responsible_gaming_policy_update IS 'Updates a responsible gaming policy. Platform Admin only.';

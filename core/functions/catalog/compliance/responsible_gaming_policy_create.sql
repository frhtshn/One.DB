-- ================================================================
-- RESPONSIBLE_GAMING_POLICY_CREATE: Yeni sorumlu oyun politikası oluşturur
-- Platform Admin (SuperAdmin + Admin) kullanabilir
-- Her jurisdiction için sadece 1 policy olabilir (1:1)
-- ================================================================

DROP FUNCTION IF EXISTS catalog.responsible_gaming_policy_create(
    BIGINT, INT,
    BOOLEAN, JSONB, INT,
    BOOLEAN, JSONB,
    BOOLEAN, INT, BOOLEAN, INT, INT,
    BOOLEAN, INT,
    BOOLEAN, INT, INT, BOOLEAN,
    BOOLEAN, INT, BOOLEAN, BOOLEAN,
    VARCHAR, BOOLEAN, VARCHAR,
    BOOLEAN, BOOLEAN, BOOLEAN, BOOLEAN
);

CREATE OR REPLACE FUNCTION catalog.responsible_gaming_policy_create(
    p_caller_id BIGINT,
    p_jurisdiction_id INT,
    -- Deposit limits
    p_deposit_limit_required BOOLEAN DEFAULT FALSE,
    p_deposit_limit_options JSONB DEFAULT NULL,
    p_deposit_limit_max_increase_wait_hours INT DEFAULT NULL,
    -- Loss limits
    p_loss_limit_required BOOLEAN DEFAULT FALSE,
    p_loss_limit_options JSONB DEFAULT NULL,
    -- Session limits
    p_session_limit_required BOOLEAN DEFAULT FALSE,
    p_session_limit_max_hours INT DEFAULT NULL,
    p_session_break_required BOOLEAN DEFAULT FALSE,
    p_session_break_after_hours INT DEFAULT NULL,
    p_session_break_duration_minutes INT DEFAULT NULL,
    -- Reality check
    p_reality_check_required BOOLEAN DEFAULT FALSE,
    p_reality_check_interval_minutes INT DEFAULT NULL,
    -- Cooling off
    p_cooling_off_available BOOLEAN DEFAULT TRUE,
    p_cooling_off_min_days INT DEFAULT 1,
    p_cooling_off_max_days INT DEFAULT 42,
    p_cooling_off_revocable BOOLEAN DEFAULT FALSE,
    -- Self exclusion
    p_self_exclusion_available BOOLEAN DEFAULT TRUE,
    p_self_exclusion_min_months INT DEFAULT 6,
    p_self_exclusion_permanent_option BOOLEAN DEFAULT TRUE,
    p_self_exclusion_revocable BOOLEAN DEFAULT FALSE,
    -- Central exclusion
    p_central_exclusion_system VARCHAR(50) DEFAULT NULL,
    p_central_exclusion_integration_required BOOLEAN DEFAULT FALSE,
    p_central_exclusion_api_endpoint VARCHAR(255) DEFAULT NULL,
    -- Payment restrictions
    p_anonymous_payments_allowed BOOLEAN DEFAULT TRUE,
    p_crypto_payments_allowed BOOLEAN DEFAULT TRUE,
    p_credit_card_gambling_allowed BOOLEAN DEFAULT TRUE,
    p_payment_method_ownership_verification BOOLEAN DEFAULT FALSE
)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_new_id INT;
BEGIN
    -- Platform Admin kontrolü (SuperAdmin veya Admin)
    IF NOT EXISTS(
        SELECT 1 FROM security.user_roles ur
        JOIN security.roles r ON ur.role_id = r.id
        WHERE ur.user_id = p_caller_id
          AND ur.tenant_id IS NULL
          AND r.code IN ('superadmin', 'admin')
          AND r.status = 1
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

    -- Jurisdiction kontrolü
    IF p_jurisdiction_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.responsible-gaming-policy.jurisdiction-required';
    END IF;

    -- Jurisdiction varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.jurisdictions j WHERE j.id = p_jurisdiction_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.jurisdiction.not-found';
    END IF;

    -- Mevcut policy kontrolü (1:1 ilişki)
    IF EXISTS(SELECT 1 FROM catalog.responsible_gaming_policies rgp WHERE rgp.jurisdiction_id = p_jurisdiction_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.responsible-gaming-policy.already-exists-for-jurisdiction';
    END IF;

    -- Ekle
    INSERT INTO catalog.responsible_gaming_policies (
        jurisdiction_id,
        deposit_limit_required, deposit_limit_options, deposit_limit_max_increase_wait_hours,
        loss_limit_required, loss_limit_options,
        session_limit_required, session_limit_max_hours,
        session_break_required, session_break_after_hours, session_break_duration_minutes,
        reality_check_required, reality_check_interval_minutes,
        cooling_off_available, cooling_off_min_days, cooling_off_max_days, cooling_off_revocable,
        self_exclusion_available, self_exclusion_min_months, self_exclusion_permanent_option, self_exclusion_revocable,
        central_exclusion_system, central_exclusion_integration_required, central_exclusion_api_endpoint,
        anonymous_payments_allowed, crypto_payments_allowed, credit_card_gambling_allowed,
        payment_method_ownership_verification,
        is_active, created_at, updated_at
    )
    VALUES (
        p_jurisdiction_id,
        COALESCE(p_deposit_limit_required, FALSE), p_deposit_limit_options, p_deposit_limit_max_increase_wait_hours,
        COALESCE(p_loss_limit_required, FALSE), p_loss_limit_options,
        COALESCE(p_session_limit_required, FALSE), p_session_limit_max_hours,
        COALESCE(p_session_break_required, FALSE), p_session_break_after_hours, p_session_break_duration_minutes,
        COALESCE(p_reality_check_required, FALSE), p_reality_check_interval_minutes,
        COALESCE(p_cooling_off_available, TRUE), COALESCE(p_cooling_off_min_days, 1),
        COALESCE(p_cooling_off_max_days, 42), COALESCE(p_cooling_off_revocable, FALSE),
        COALESCE(p_self_exclusion_available, TRUE), COALESCE(p_self_exclusion_min_months, 6),
        COALESCE(p_self_exclusion_permanent_option, TRUE), COALESCE(p_self_exclusion_revocable, FALSE),
        p_central_exclusion_system, COALESCE(p_central_exclusion_integration_required, FALSE), p_central_exclusion_api_endpoint,
        COALESCE(p_anonymous_payments_allowed, TRUE), COALESCE(p_crypto_payments_allowed, TRUE),
        COALESCE(p_credit_card_gambling_allowed, TRUE), COALESCE(p_payment_method_ownership_verification, FALSE),
        TRUE, NOW(), NOW()
    )
    RETURNING catalog.responsible_gaming_policies.id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION catalog.responsible_gaming_policy_create IS 'Creates a responsible gaming policy. Platform Admin only. One per jurisdiction.';

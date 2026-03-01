-- ================================================================
-- RISK_ASSESSMENT_CREATE: Risk değerlendirmesi oluştur
-- ================================================================
-- Oyuncu risk skorunu hesaplar ve kaydeder.
-- Birden fazla risk faktörü bileşeni saklanır.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc_audit.risk_assessment_create(BIGINT, VARCHAR, INT, VARCHAR, VARCHAR, JSONB, INT, INT, INT, INT, INT, INT, VARCHAR, BIGINT, JSONB, JSONB, VARCHAR, BIGINT, TIMESTAMP);

CREATE OR REPLACE FUNCTION kyc_audit.risk_assessment_create(
    p_player_id             BIGINT,
    p_assessment_type       VARCHAR(30),
    p_risk_score            INT,
    p_risk_level            VARCHAR(20),
    p_previous_risk_level   VARCHAR(20) DEFAULT NULL,
    p_risk_factors          JSONB DEFAULT '{}'::JSONB,
    p_country_risk_score    INT DEFAULT 0,
    p_occupation_risk_score INT DEFAULT 0,
    p_pep_risk_score        INT DEFAULT 0,
    p_transaction_risk_score INT DEFAULT 0,
    p_sof_risk_score        INT DEFAULT 0,
    p_behavioral_risk_score INT DEFAULT 0,
    p_trigger_event         VARCHAR(50) DEFAULT NULL,
    p_trigger_reference_id  BIGINT DEFAULT NULL,
    p_trigger_details       JSONB DEFAULT NULL,
    p_recommended_actions   JSONB DEFAULT NULL,
    p_assessed_by           VARCHAR(20) DEFAULT 'system',
    p_admin_user_id         BIGINT DEFAULT NULL,
    p_valid_until           TIMESTAMP DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_id          BIGINT;
    v_risk_change VARCHAR(20);
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-risk.player-required';
    END IF;

    IF p_assessment_type IS NULL OR TRIM(p_assessment_type) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-risk.type-required';
    END IF;

    IF p_risk_level IS NULL OR TRIM(p_risk_level) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-risk.level-required';
    END IF;

    -- Risk değişim yönü
    IF p_previous_risk_level IS NOT NULL THEN
        IF p_risk_level = p_previous_risk_level THEN
            v_risk_change := 'unchanged';
        ELSIF p_risk_score > 0 THEN
            v_risk_change := 'increased';
        ELSE
            v_risk_change := 'decreased';
        END IF;
    END IF;

    INSERT INTO kyc_audit.player_risk_assessments (
        player_id, assessment_type, risk_score, risk_level,
        previous_risk_level, risk_change, risk_factors,
        country_risk_score, occupation_risk_score, pep_risk_score,
        transaction_risk_score, sof_risk_score, behavioral_risk_score,
        trigger_event, trigger_reference_id, trigger_details,
        recommended_actions, assessed_by, admin_user_id, valid_until
    ) VALUES (
        p_player_id, p_assessment_type, p_risk_score, p_risk_level,
        p_previous_risk_level, v_risk_change, COALESCE(p_risk_factors, '{}'::JSONB),
        COALESCE(p_country_risk_score, 0), COALESCE(p_occupation_risk_score, 0),
        COALESCE(p_pep_risk_score, 0), COALESCE(p_transaction_risk_score, 0),
        COALESCE(p_sof_risk_score, 0), COALESCE(p_behavioral_risk_score, 0),
        p_trigger_event, p_trigger_reference_id, p_trigger_details,
        p_recommended_actions, COALESCE(p_assessed_by, 'system'), p_admin_user_id, p_valid_until
    )
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

COMMENT ON FUNCTION kyc_audit.risk_assessment_create IS 'Creates a risk assessment with composite risk scores and factor breakdown. Tracks risk level changes.';

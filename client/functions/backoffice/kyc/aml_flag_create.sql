-- ================================================================
-- AML_FLAG_CREATE: AML şüpheli işlem bayrağı oluştur
-- ================================================================
-- Otomatik (kural motoru) veya manuel AML flag oluşturur.
-- Kural, işlem ve kanıt detayları JSONB olarak saklanır.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.aml_flag_create(BIGINT, VARCHAR, VARCHAR, TEXT, VARCHAR, VARCHAR, VARCHAR, JSONB, JSONB, DECIMAL, DECIMAL, CHAR, TIMESTAMP, TIMESTAMP, INT);

CREATE OR REPLACE FUNCTION kyc.aml_flag_create(
    p_player_id            BIGINT,
    p_flag_type            VARCHAR(50),
    p_severity             VARCHAR(20),
    p_description          TEXT,
    p_detection_method     VARCHAR(30),
    p_rule_id              VARCHAR(50) DEFAULT NULL,
    p_rule_name            VARCHAR(100) DEFAULT NULL,
    p_related_transactions JSONB DEFAULT NULL,
    p_evidence_data        JSONB DEFAULT NULL,
    p_threshold_amount     DECIMAL(18,2) DEFAULT NULL,
    p_actual_amount        DECIMAL(18,2) DEFAULT NULL,
    p_currency_code        CHAR(3) DEFAULT NULL,
    p_period_start         TIMESTAMP DEFAULT NULL,
    p_period_end           TIMESTAMP DEFAULT NULL,
    p_transaction_count    INT DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_flag_id BIGINT;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-aml.player-required';
    END IF;

    IF p_flag_type IS NULL OR TRIM(p_flag_type) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-aml.flag-type-required';
    END IF;

    IF p_severity IS NULL OR TRIM(p_severity) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-aml.severity-required';
    END IF;

    IF p_description IS NULL OR TRIM(p_description) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-aml.description-required';
    END IF;

    -- Oyuncu kontrolü
    IF NOT EXISTS (SELECT 1 FROM auth.players WHERE id = p_player_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-aml.player-not-found';
    END IF;

    INSERT INTO kyc.player_aml_flags (
        player_id, flag_type, severity, description, detection_method,
        rule_id, rule_name, related_transactions, evidence_data,
        threshold_amount, actual_amount, currency_code,
        period_start, period_end, transaction_count
    ) VALUES (
        p_player_id, p_flag_type, p_severity, p_description, p_detection_method,
        p_rule_id, p_rule_name, p_related_transactions, p_evidence_data,
        p_threshold_amount, p_actual_amount, p_currency_code,
        p_period_start, p_period_end, p_transaction_count
    )
    RETURNING id INTO v_flag_id;

    RETURN v_flag_id;
END;
$$;

COMMENT ON FUNCTION kyc.aml_flag_create IS 'Creates an AML suspicious activity flag. Can be automated (rule engine) or manual. Stores rule details and evidence as JSONB.';

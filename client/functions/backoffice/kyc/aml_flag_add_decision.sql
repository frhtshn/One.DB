-- ================================================================
-- AML_FLAG_ADD_DECISION: AML soruşturma kararı ekle
-- ================================================================
-- Soruşturma sonucu karar ve aksiyonları kaydeder.
-- SAR (Suspicious Activity Report) bilgileri dahil.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.aml_flag_add_decision(BIGINT, VARCHAR, BIGINT, TEXT, BOOLEAN, VARCHAR, JSONB);

CREATE OR REPLACE FUNCTION kyc.aml_flag_add_decision(
    p_flag_id        BIGINT,
    p_decision       VARCHAR(50),
    p_decision_by    BIGINT,
    p_decision_reason TEXT DEFAULT NULL,
    p_sar_required   BOOLEAN DEFAULT FALSE,
    p_sar_reference  VARCHAR(100) DEFAULT NULL,
    p_actions_taken  JSONB DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_flag_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-aml.flag-required';
    END IF;

    IF p_decision IS NULL OR TRIM(p_decision) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-aml.decision-required';
    END IF;

    IF p_decision_by IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-aml.decision-by-required';
    END IF;

    -- Flag kontrolü
    IF NOT EXISTS (SELECT 1 FROM kyc.player_aml_flags WHERE id = p_flag_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-aml.not-found';
    END IF;

    UPDATE kyc.player_aml_flags
    SET decision = p_decision,
        decision_by = p_decision_by,
        decision_at = NOW(),
        decision_reason = p_decision_reason,
        sar_required = COALESCE(p_sar_required, FALSE),
        sar_reference = p_sar_reference,
        actions_taken = p_actions_taken,
        status = 'closed',
        closed_at = NOW(),
        updated_at = NOW()
    WHERE id = p_flag_id;
END;
$$;

COMMENT ON FUNCTION kyc.aml_flag_add_decision IS 'Records investigation decision with SAR details and actions taken. Automatically closes the flag.';

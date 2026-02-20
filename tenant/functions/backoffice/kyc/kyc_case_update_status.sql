-- ================================================================
-- KYC_CASE_UPDATE_STATUS: KYC case durumunu güncelle
-- ================================================================
-- Case durumunu değiştirir ve workflow kaydı oluşturur.
-- Durum geçiş geçmişi tutulur.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.kyc_case_update_status(BIGINT, VARCHAR, VARCHAR, BIGINT);

CREATE OR REPLACE FUNCTION kyc.kyc_case_update_status(
    p_case_id      BIGINT,
    p_new_status   VARCHAR(30),
    p_reason       VARCHAR(255) DEFAULT NULL,
    p_performed_by BIGINT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_old_status VARCHAR(30);
BEGIN
    IF p_case_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-case.case-required';
    END IF;

    IF p_new_status IS NULL OR TRIM(p_new_status) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-case.status-required';
    END IF;

    -- Mevcut durumu al
    SELECT current_status INTO v_old_status
    FROM kyc.player_kyc_cases
    WHERE id = p_case_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-case.not-found';
    END IF;

    -- Aynı duruma güncelleme kontrolü
    IF v_old_status = p_new_status THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-case.status-unchanged';
    END IF;

    -- Case güncelle
    UPDATE kyc.player_kyc_cases
    SET current_status = p_new_status,
        last_decision_reason = COALESCE(p_reason, last_decision_reason),
        updated_at = NOW()
    WHERE id = p_case_id;

    -- Workflow kaydı
    INSERT INTO kyc.player_kyc_workflows (
        kyc_case_id, previous_status, current_status, action,
        performed_by, reason
    ) VALUES (
        p_case_id, v_old_status, p_new_status, 'STATUS_CHANGE',
        p_performed_by, p_reason
    );
END;
$$;

COMMENT ON FUNCTION kyc.kyc_case_update_status IS 'Updates KYC case status with workflow history. Tracks previous status for audit trail.';

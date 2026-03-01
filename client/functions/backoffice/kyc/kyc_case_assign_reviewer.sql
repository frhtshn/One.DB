-- ================================================================
-- KYC_CASE_ASSIGN_REVIEWER: İnceleme görevlisi ata
-- ================================================================
-- KYC case'e inceleme yapacak operatörü atar.
-- Workflow kaydı oluşturur.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.kyc_case_assign_reviewer(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION kyc.kyc_case_assign_reviewer(
    p_case_id     BIGINT,
    p_reviewer_id BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_status VARCHAR(30);
BEGIN
    IF p_case_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-case.case-required';
    END IF;

    IF p_reviewer_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-case.reviewer-required';
    END IF;

    -- Case kontrolü
    SELECT current_status INTO v_current_status
    FROM kyc.player_kyc_cases
    WHERE id = p_case_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-case.not-found';
    END IF;

    -- Reviewer ata
    UPDATE kyc.player_kyc_cases
    SET assigned_reviewer_id = p_reviewer_id,
        updated_at = NOW()
    WHERE id = p_case_id;

    -- Workflow kaydı
    INSERT INTO kyc.player_kyc_workflows (
        kyc_case_id, current_status, action, performed_by
    ) VALUES (
        p_case_id, v_current_status, 'ASSIGN_REVIEWER', p_reviewer_id
    );
END;
$$;

COMMENT ON FUNCTION kyc.kyc_case_assign_reviewer IS 'Assigns a reviewer to a KYC case with workflow audit entry.';

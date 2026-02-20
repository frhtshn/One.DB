-- ================================================================
-- SCREENING_RESULT_REVIEW: Tarama sonucu inceleme
-- ================================================================
-- Tarama sonucunu inceler ve karar verir.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc_audit.screening_result_review(BIGINT, VARCHAR, BIGINT, TEXT);

CREATE OR REPLACE FUNCTION kyc_audit.screening_result_review(
    p_screening_id    BIGINT,
    p_review_decision VARCHAR(30),
    p_reviewed_by     BIGINT,
    p_review_notes    TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_screening_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-screening.screening-required';
    END IF;

    IF p_review_decision IS NULL OR TRIM(p_review_decision) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-screening.decision-required';
    END IF;

    IF p_reviewed_by IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-screening.reviewer-required';
    END IF;

    -- Kayıt kontrolü
    IF NOT EXISTS (SELECT 1 FROM kyc_audit.player_screening_results WHERE id = p_screening_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-screening.not-found';
    END IF;

    UPDATE kyc_audit.player_screening_results
    SET review_status = 'reviewed',
        review_decision = p_review_decision,
        reviewed_by = p_reviewed_by,
        reviewed_at = NOW(),
        review_notes = p_review_notes
    WHERE id = p_screening_id;
END;
$$;

COMMENT ON FUNCTION kyc_audit.screening_result_review IS 'Reviews a screening result with decision and notes.';

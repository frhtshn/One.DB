-- ================================================================
-- BONUS_REQUEST_REJECT: Bonus talebini reddet
-- ================================================================
-- assigned veya in_progress durumundaki talebi reddeder.
-- review_note (red nedeni) zorunludur.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_request_reject(BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION bonus.bonus_request_reject(
    p_request_id        BIGINT,
    p_reviewed_by_id    BIGINT,
    p_review_note       VARCHAR(500)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_status VARCHAR(20);
BEGIN
    -- Red nedeni zorunlu
    IF p_review_note IS NULL OR p_review_note = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request.review-note-required';
    END IF;

    -- Talep kontrolü
    SELECT status INTO v_current_status
    FROM bonus.bonus_requests
    WHERE id = p_request_id;

    IF v_current_status IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.bonus-request.not-found';
    END IF;

    IF v_current_status NOT IN ('assigned', 'in_progress') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request.invalid-status';
    END IF;

    -- Güncelle
    UPDATE bonus.bonus_requests SET
        status = 'rejected',
        reviewed_by_id = p_reviewed_by_id,
        review_note = p_review_note,
        reviewed_at = NOW(),
        updated_at = NOW()
    WHERE id = p_request_id;

    -- Aksiyon logu
    INSERT INTO bonus.bonus_request_actions (
        request_id, action, performed_by_id, performed_by_type, note, created_at
    ) VALUES (
        p_request_id, 'REJECTED', p_reviewed_by_id, 'BO_USER', p_review_note, NOW()
    );
END;
$$;

COMMENT ON FUNCTION bonus.bonus_request_reject IS 'Rejects a bonus request with a mandatory review note. Only assigned or in-progress requests can be rejected.';

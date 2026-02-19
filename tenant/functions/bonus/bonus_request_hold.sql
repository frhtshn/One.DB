-- ================================================================
-- BONUS_REQUEST_HOLD: Talebi beklemeye al
-- ================================================================
-- in_progress durumundaki talebi on_hold'a geçirir.
-- Bekleme nedeni (hold_reason) zorunludur.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_request_hold(BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION bonus.bonus_request_hold(
    p_request_id        BIGINT,
    p_performed_by_id   BIGINT,
    p_hold_reason       VARCHAR(500)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_status VARCHAR(20);
BEGIN
    -- Neden zorunlu
    IF p_hold_reason IS NULL OR p_hold_reason = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request.hold-reason-required';
    END IF;

    -- Talep kontrolü
    SELECT status INTO v_current_status
    FROM bonus.bonus_requests
    WHERE id = p_request_id;

    IF v_current_status IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.bonus-request.not-found';
    END IF;

    IF v_current_status <> 'in_progress' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request.invalid-status';
    END IF;

    -- Güncelle
    UPDATE bonus.bonus_requests SET
        status = 'on_hold',
        updated_at = NOW()
    WHERE id = p_request_id;

    -- Aksiyon logu
    INSERT INTO bonus.bonus_request_actions (
        request_id, action, performed_by_id, performed_by_type, note, created_at
    ) VALUES (
        p_request_id, 'ON_HOLD', p_performed_by_id, 'BO_USER', p_hold_reason, NOW()
    );
END;
$$;

COMMENT ON FUNCTION bonus.bonus_request_hold IS 'Puts an in-progress bonus request on hold with a mandatory reason. Use start_review to resume.';

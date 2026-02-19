-- ================================================================
-- BONUS_REQUEST_CANCEL: Bonus talebini iptal et
-- ================================================================
-- pending veya assigned durumundaki talebi iptal eder.
-- Oyuncu veya BO operatör tarafından çağrılabilir.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_request_cancel(BIGINT, BIGINT, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION bonus.bonus_request_cancel(
    p_request_id        BIGINT,
    p_cancelled_by_id   BIGINT,
    p_cancelled_by_type VARCHAR(20),
    p_note              VARCHAR(500) DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_status VARCHAR(20);
BEGIN
    -- Talep kontrolü
    SELECT status INTO v_current_status
    FROM bonus.bonus_requests
    WHERE id = p_request_id;

    IF v_current_status IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.bonus-request.not-found';
    END IF;

    IF v_current_status NOT IN ('pending', 'assigned') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request.invalid-status';
    END IF;

    -- Güncelle
    UPDATE bonus.bonus_requests SET
        status = 'cancelled',
        updated_at = NOW()
    WHERE id = p_request_id;

    -- Aksiyon logu
    INSERT INTO bonus.bonus_request_actions (
        request_id, action, performed_by_id, performed_by_type, note, created_at
    ) VALUES (
        p_request_id, 'CANCELLED', p_cancelled_by_id,
        COALESCE(p_cancelled_by_type, 'BO_USER'),
        p_note, NOW()
    );
END;
$$;

COMMENT ON FUNCTION bonus.bonus_request_cancel IS 'Cancels a bonus request. Only pending or assigned requests can be cancelled. Can be invoked by player or BO operator.';

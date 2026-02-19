-- ================================================================
-- BONUS_REQUEST_ASSIGN: Bonus talebini operatöre ata
-- ================================================================
-- pending veya assigned durumundaki talebi operatöre atar.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_request_assign(BIGINT, BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION bonus.bonus_request_assign(
    p_request_id        BIGINT,
    p_assigned_to_id    BIGINT,
    p_performed_by_id   BIGINT,
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
        status = 'assigned',
        assigned_to_id = p_assigned_to_id,
        assigned_at = NOW(),
        updated_at = NOW()
    WHERE id = p_request_id;

    -- Aksiyon logu
    INSERT INTO bonus.bonus_request_actions (
        request_id, action, performed_by_id, performed_by_type, note, created_at
    ) VALUES (
        p_request_id, 'ASSIGNED', p_performed_by_id, 'BO_USER', p_note, NOW()
    );
END;
$$;

COMMENT ON FUNCTION bonus.bonus_request_assign IS 'Assigns a bonus request to a BO operator. Only pending or assigned requests can be reassigned.';

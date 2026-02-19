-- ================================================================
-- BONUS_REQUEST_START_REVIEW: Talebi işleme al
-- ================================================================
-- pending, assigned veya on_hold durumundaki talebi in_progress'e
-- geçirir. Operatör kendine atar ve "X inceliyor" olarak görünür.
-- on_hold'dan geliyorsa aksiyon RESUMED olarak loglanır.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_request_start_review(BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION bonus.bonus_request_start_review(
    p_request_id        BIGINT,
    p_performed_by_id   BIGINT,
    p_note              VARCHAR(500) DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_status VARCHAR(20);
    v_action_type    VARCHAR(30);
BEGIN
    -- Talep kontrolü
    SELECT status INTO v_current_status
    FROM bonus.bonus_requests
    WHERE id = p_request_id;

    IF v_current_status IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.bonus-request.not-found';
    END IF;

    IF v_current_status NOT IN ('pending', 'assigned', 'on_hold') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request.invalid-status';
    END IF;

    -- Aksiyon tipini belirle
    v_action_type := CASE
        WHEN v_current_status = 'on_hold' THEN 'RESUMED'
        ELSE 'REVIEW_STARTED'
    END;

    -- Güncelle
    UPDATE bonus.bonus_requests SET
        status = 'in_progress',
        assigned_to_id = p_performed_by_id,
        assigned_at = COALESCE(assigned_at, NOW()),
        updated_at = NOW()
    WHERE id = p_request_id;

    -- Aksiyon logu
    INSERT INTO bonus.bonus_request_actions (
        request_id, action, performed_by_id, performed_by_type, note, created_at
    ) VALUES (
        p_request_id, v_action_type, p_performed_by_id, 'BO_USER', p_note, NOW()
    );
END;
$$;

COMMENT ON FUNCTION bonus.bonus_request_start_review IS 'Takes a bonus request into active review (in_progress). Assigns the reviewer and creates REVIEW_STARTED or RESUMED action based on previous status.';

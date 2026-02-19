-- ================================================================
-- BONUS_REQUEST_ROLLBACK: Onay veya reddi geri al
-- ================================================================
-- completed veya rejected durumundaki talebi in_progress'e döndürür.
-- completed rollback: bonus_award_cancel() çağrılır, wallet geri çekilir.
-- rejected rollback: sadece durum değişir, yeniden inceleme yapılır.
-- Rollback yapan operatör talebin sahibi olur.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_request_rollback(BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION bonus.bonus_request_rollback(
    p_request_id        BIGINT,
    p_performed_by_id   BIGINT,
    p_rollback_reason   VARCHAR(500)
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_request           RECORD;
    v_action_data       JSONB;
BEGIN
    -- Neden zorunlu
    IF p_rollback_reason IS NULL OR p_rollback_reason = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request.rollback-reason-required';
    END IF;

    -- Talep kontrolü
    SELECT * INTO v_request
    FROM bonus.bonus_requests
    WHERE id = p_request_id;

    IF v_request IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.bonus-request.not-found';
    END IF;

    IF v_request.status NOT IN ('completed', 'rejected') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-request.rollback-not-allowed';
    END IF;

    -- Aksiyon data hazırla
    v_action_data := jsonb_build_object('previous_status', v_request.status);

    -- Completed rollback: bonus award iptal et
    IF v_request.status = 'completed' AND v_request.bonus_award_id IS NOT NULL THEN
        -- bonus_award_cancel çağır (BONUS wallet'tan geri çeker)
        PERFORM bonus.bonus_award_cancel(
            p_id := v_request.bonus_award_id,
            p_cancellation_reason := 'Bonus request rollback: ' || p_rollback_reason,
            p_cancelled_by := p_performed_by_id
        );

        v_action_data := v_action_data || jsonb_build_object(
            'cancelled_award_id', v_request.bonus_award_id,
            'cancelled_amount', v_request.approved_amount,
            'cancelled_currency', v_request.approved_currency
        );
    END IF;

    -- Talebi in_progress'e döndür
    UPDATE bonus.bonus_requests SET
        status = 'in_progress',
        reviewed_by_id = NULL,
        reviewed_at = NULL,
        review_note = NULL,
        approved_amount = CASE WHEN v_request.status = 'completed' THEN NULL ELSE approved_amount END,
        approved_currency = CASE WHEN v_request.status = 'completed' THEN NULL ELSE approved_currency END,
        approved_bonus_type = CASE WHEN v_request.status = 'completed' THEN NULL ELSE approved_bonus_type END,
        bonus_award_id = NULL,
        assigned_to_id = p_performed_by_id,
        assigned_at = NOW(),
        updated_at = NOW()
    WHERE id = p_request_id;

    -- Aksiyon logu
    INSERT INTO bonus.bonus_request_actions (
        request_id, action, performed_by_id, performed_by_type,
        note, action_data, created_at
    ) VALUES (
        p_request_id, 'ROLLBACK', p_performed_by_id, 'BO_USER',
        p_rollback_reason, v_action_data, NOW()
    );
END;
$$;

COMMENT ON FUNCTION bonus.bonus_request_rollback IS 'Rolls back a completed or rejected bonus request to in_progress. For completed requests, cancels the bonus award and reverts wallet balance. The operator performing rollback becomes the assignee.';

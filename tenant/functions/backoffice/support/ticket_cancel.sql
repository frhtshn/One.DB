-- ================================================================
-- TICKET_CANCEL: Ticket iptal et (BO/Oyuncu)
-- ================================================================
-- Ticket'ı iptal eder. Final durum.
-- closed ve cancelled dışındaki tüm statuslardan iptal edilebilir.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.ticket_cancel(BIGINT, BIGINT, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION support.ticket_cancel(
    p_ticket_id         BIGINT,
    p_performed_by_id   BIGINT,
    p_performed_by_type VARCHAR(10),
    p_note              VARCHAR(500) DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_old_status    VARCHAR(20);
BEGIN
    -- Ticket kontrolü
    SELECT status INTO v_old_status
    FROM support.tickets
    WHERE id = p_ticket_id;

    IF v_old_status IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.support.ticket-not-found';
    END IF;

    -- closed ve cancelled'dan iptal edilemez
    IF v_old_status IN ('closed', 'cancelled') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.support.ticket-closed';
    END IF;

    -- performed_by_type validasyonu
    IF p_performed_by_type NOT IN ('PLAYER', 'BO_USER') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.invalid-created-by-type';
    END IF;

    -- Ticket güncelle
    UPDATE support.tickets
    SET status = 'cancelled',
        updated_at = NOW()
    WHERE id = p_ticket_id;

    -- Aksiyon logu
    INSERT INTO support.ticket_actions (
        ticket_id, action, performed_by_id, performed_by_type,
        old_status, new_status, content, created_at
    ) VALUES (
        p_ticket_id, 'CANCELLED', p_performed_by_id, p_performed_by_type,
        v_old_status, 'cancelled', p_note, NOW()
    );
END;
$$;

COMMENT ON FUNCTION support.ticket_cancel IS 'Cancels a ticket from any status except closed and cancelled. Final status.';

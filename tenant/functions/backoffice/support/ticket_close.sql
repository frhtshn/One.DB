-- ================================================================
-- TICKET_CLOSE: Ticket kapat (BO)
-- ================================================================
-- Çözülmüş ticket'ı kapatır. Final durum.
-- Geçerli status: resolved.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.ticket_close(BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION support.ticket_close(
    p_ticket_id         BIGINT,
    p_performed_by_id   BIGINT,
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

    -- Status kontrolü
    IF v_old_status <> 'resolved' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.support.ticket-invalid-status';
    END IF;

    -- Ticket güncelle
    UPDATE support.tickets
    SET status = 'closed',
        closed_at = NOW(),
        updated_at = NOW()
    WHERE id = p_ticket_id;

    -- Aksiyon logu
    INSERT INTO support.ticket_actions (
        ticket_id, action, performed_by_id, performed_by_type,
        old_status, new_status, content, created_at
    ) VALUES (
        p_ticket_id, 'CLOSED', p_performed_by_id, 'BO_USER',
        'resolved', 'closed', p_note, NOW()
    );
END;
$$;

COMMENT ON FUNCTION support.ticket_close IS 'Closes a resolved ticket. Final status - can only be reopened via ticket_reopen.';

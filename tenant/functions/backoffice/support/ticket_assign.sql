-- ================================================================
-- TICKET_ASSIGN: Ticket temsilciye ata (BO)
-- ================================================================
-- Ticket'ı temsilciye atar veya başka temsilciye devreder.
-- Geçerli statuslar: open, assigned, reopened.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.ticket_assign(BIGINT, BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION support.ticket_assign(
    p_ticket_id         BIGINT,
    p_assigned_to_id    BIGINT,
    p_performed_by_id   BIGINT,
    p_note              VARCHAR(500) DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_ticket        RECORD;
    v_action        VARCHAR(30);
    v_old_status    VARCHAR(20);
BEGIN
    -- Ticket kontrolü
    SELECT id, status, assigned_to_id
    INTO v_ticket
    FROM support.tickets
    WHERE id = p_ticket_id;

    IF v_ticket.id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.support.ticket-not-found';
    END IF;

    -- Status kontrolü: sadece open, assigned, reopened
    IF v_ticket.status NOT IN ('open', 'assigned', 'reopened') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.support.ticket-invalid-status';
    END IF;

    -- Aynı temsilci kontrolü
    IF v_ticket.assigned_to_id IS NOT NULL AND v_ticket.assigned_to_id = p_assigned_to_id THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.support.ticket-already-assigned';
    END IF;

    -- Aksiyon tipi belirle
    v_action := CASE
        WHEN v_ticket.assigned_to_id IS NOT NULL THEN 'REASSIGNED'
        ELSE 'ASSIGNED'
    END;
    v_old_status := v_ticket.status;

    -- Ticket güncelle
    UPDATE support.tickets
    SET assigned_to_id = p_assigned_to_id,
        assigned_at = NOW(),
        status = 'assigned',
        updated_at = NOW()
    WHERE id = p_ticket_id;

    -- Aksiyon logu
    INSERT INTO support.ticket_actions (
        ticket_id, action, performed_by_id, performed_by_type,
        old_status, new_status, content,
        action_data, created_at
    ) VALUES (
        p_ticket_id, v_action, p_performed_by_id, 'BO_USER',
        v_old_status, 'assigned', p_note,
        jsonb_build_object('assignedToId', p_assigned_to_id),
        NOW()
    );
END;
$$;

COMMENT ON FUNCTION support.ticket_assign IS 'Assigns or reassigns a ticket to a support agent. Valid from open, assigned, or reopened status.';

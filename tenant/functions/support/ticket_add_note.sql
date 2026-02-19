-- ================================================================
-- TICKET_ADD_NOTE: Ticket'a not ekle (BO)
-- ================================================================
-- Dahili veya harici not ekler. Status değiştirmez.
-- Kapalı/iptal ticket'a not eklenemez.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.ticket_add_note(BIGINT, BIGINT, TEXT, BOOLEAN);

CREATE OR REPLACE FUNCTION support.ticket_add_note(
    p_ticket_id         BIGINT,
    p_performed_by_id   BIGINT,
    p_content           TEXT,
    p_is_internal       BOOLEAN DEFAULT true
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_ticket_status VARCHAR(20);
    v_action_id     BIGINT;
BEGIN
    -- Ticket kontrolü
    SELECT status INTO v_ticket_status
    FROM support.tickets
    WHERE id = p_ticket_id;

    IF v_ticket_status IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.support.ticket-not-found';
    END IF;

    -- Kapalı/iptal ticket'a not eklenemez
    IF v_ticket_status IN ('closed', 'cancelled') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.support.ticket-closed';
    END IF;

    -- İçerik kontrolü
    IF p_content IS NULL OR TRIM(p_content) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.description-required';
    END IF;

    -- Aksiyon logu (status değişmez)
    INSERT INTO support.ticket_actions (
        ticket_id, action, performed_by_id, performed_by_type,
        content, is_internal, created_at
    ) VALUES (
        p_ticket_id, 'REPLIED_INTERNAL', p_performed_by_id, 'BO_USER',
        p_content, p_is_internal, NOW()
    )
    RETURNING id INTO v_action_id;

    -- updated_at güncelle
    UPDATE support.tickets SET updated_at = NOW() WHERE id = p_ticket_id;

    RETURN v_action_id;
END;
$$;

COMMENT ON FUNCTION support.ticket_add_note IS 'Adds an internal or external note to a ticket. Does not change ticket status. Cannot add to closed/cancelled tickets.';

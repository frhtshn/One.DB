-- ================================================================
-- TICKET_REPLY_PLAYER: Oyuncuya yanıt ver (BO)
-- ================================================================
-- Temsilci oyuncuya yanıt gönderir. pending_player durumundaysa
-- status in_progress'e döner.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.ticket_reply_player(BIGINT, BIGINT, TEXT, VARCHAR);

CREATE OR REPLACE FUNCTION support.ticket_reply_player(
    p_ticket_id         BIGINT,
    p_performed_by_id   BIGINT,
    p_content           TEXT,
    p_channel           VARCHAR(20) DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_ticket    RECORD;
    v_action_id BIGINT;
BEGIN
    -- Ticket kontrolü
    SELECT id, status INTO v_ticket
    FROM support.tickets
    WHERE id = p_ticket_id;

    IF v_ticket.id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.support.ticket-not-found';
    END IF;

    -- Kapalı/iptal ticket'a yanıt verilemez
    IF v_ticket.status IN ('closed', 'cancelled') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.support.ticket-closed';
    END IF;

    -- İçerik kontrolü
    IF p_content IS NULL OR TRIM(p_content) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.description-required';
    END IF;

    -- Aksiyon logu
    INSERT INTO support.ticket_actions (
        ticket_id, action, performed_by_id, performed_by_type,
        content, is_internal, channel, created_at
    ) VALUES (
        p_ticket_id, 'REPLIED_PLAYER', p_performed_by_id, 'BO_USER',
        p_content, false, p_channel, NOW()
    )
    RETURNING id INTO v_action_id;

    -- pending_player durumundaysa in_progress'e geç
    IF v_ticket.status = 'pending_player' THEN
        UPDATE support.tickets
        SET status = 'in_progress', updated_at = NOW()
        WHERE id = p_ticket_id;

        -- Status değişikliği için ek aksiyon logu
        UPDATE support.ticket_actions
        SET old_status = 'pending_player', new_status = 'in_progress'
        WHERE id = v_action_id;
    ELSE
        UPDATE support.tickets SET updated_at = NOW() WHERE id = p_ticket_id;
    END IF;

    RETURN v_action_id;
END;
$$;

COMMENT ON FUNCTION support.ticket_reply_player IS 'Agent replies to a player on a ticket. If ticket is in pending_player status, transitions to in_progress.';

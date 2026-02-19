-- ================================================================
-- PLAYER_TICKET_REPLY: Oyuncu yanıt ver
-- ================================================================
-- Oyuncu kendi ticket'ına yanıt verir.
-- pending_player durumundaysa in_progress'e döner.
-- Kapalı/iptal ticket'a yanıt verilemez.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.player_ticket_reply(BIGINT, BIGINT, TEXT);

CREATE OR REPLACE FUNCTION support.player_ticket_reply(
    p_player_id     BIGINT,
    p_ticket_id     BIGINT,
    p_content       TEXT
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_ticket    RECORD;
    v_action_id BIGINT;
BEGIN
    -- Ticket kontrolü + sahiplik
    SELECT id, status, player_id INTO v_ticket
    FROM support.tickets
    WHERE id = p_ticket_id;

    IF v_ticket.id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.support.ticket-not-found';
    END IF;

    IF v_ticket.player_id <> p_player_id THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.support.ticket-not-owner';
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
        content, is_internal, created_at
    ) VALUES (
        p_ticket_id, 'PLAYER_REPLIED', p_player_id, 'PLAYER',
        p_content, false, NOW()
    )
    RETURNING id INTO v_action_id;

    -- pending_player durumundaysa in_progress'e geç
    IF v_ticket.status = 'pending_player' THEN
        UPDATE support.tickets
        SET status = 'in_progress', updated_at = NOW()
        WHERE id = p_ticket_id;

        UPDATE support.ticket_actions
        SET old_status = 'pending_player', new_status = 'in_progress'
        WHERE id = v_action_id;
    ELSE
        UPDATE support.tickets SET updated_at = NOW() WHERE id = p_ticket_id;
    END IF;

    RETURN v_action_id;
END;
$$;

COMMENT ON FUNCTION support.player_ticket_reply IS 'Player replies to their own ticket. If ticket is in pending_player status, transitions to in_progress.';

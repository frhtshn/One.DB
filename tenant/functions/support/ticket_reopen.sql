-- ================================================================
-- TICKET_REOPEN: Ticket tekrar aç (BO/Oyuncu)
-- ================================================================
-- Çözülmüş veya kapatılmış ticket'ı tekrar açar.
-- Geçerli statuslar: resolved, closed.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.ticket_reopen(BIGINT, BIGINT, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION support.ticket_reopen(
    p_ticket_id         BIGINT,
    p_performed_by_id   BIGINT,
    p_performed_by_type VARCHAR(10),
    p_reason            VARCHAR(500)
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
    IF v_old_status NOT IN ('resolved', 'closed') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.support.ticket-invalid-status';
    END IF;

    -- performed_by_type validasyonu
    IF p_performed_by_type NOT IN ('PLAYER', 'BO_USER') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.invalid-created-by-type';
    END IF;

    -- Ticket güncelle: resolved/closed alanlarını temizle
    UPDATE support.tickets
    SET status = 'reopened',
        resolved_by_id = NULL,
        resolved_at = NULL,
        closed_at = NULL,
        updated_at = NOW()
    WHERE id = p_ticket_id;

    -- Aksiyon logu
    INSERT INTO support.ticket_actions (
        ticket_id, action, performed_by_id, performed_by_type,
        old_status, new_status, content, created_at
    ) VALUES (
        p_ticket_id, 'REOPENED', p_performed_by_id, p_performed_by_type,
        v_old_status, 'reopened', p_reason, NOW()
    );
END;
$$;

COMMENT ON FUNCTION support.ticket_reopen IS 'Reopens a resolved or closed ticket. Clears resolution and closure timestamps.';

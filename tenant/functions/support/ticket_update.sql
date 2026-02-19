-- ================================================================
-- TICKET_UPDATE: Ticket güncelle (priority/category, BO)
-- ================================================================
-- Ticket öncelik ve/veya kategori güncellemesi.
-- Her değişiklik ayrı aksiyon logu oluşturur.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.ticket_update(BIGINT, BIGINT, SMALLINT, BIGINT);

CREATE OR REPLACE FUNCTION support.ticket_update(
    p_ticket_id         BIGINT,
    p_performed_by_id   BIGINT,
    p_priority          SMALLINT DEFAULT NULL,
    p_category_id       BIGINT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_ticket    RECORD;
BEGIN
    -- Ticket kontrolü
    SELECT id, priority, category_id, status
    INTO v_ticket
    FROM support.tickets
    WHERE id = p_ticket_id;

    IF v_ticket.id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.support.ticket-not-found';
    END IF;

    -- Kapalı/iptal ticket güncellenemez
    IF v_ticket.status IN ('closed', 'cancelled') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.support.ticket-closed';
    END IF;

    -- Priority güncelleme
    IF p_priority IS NOT NULL AND p_priority <> v_ticket.priority THEN
        IF p_priority < 0 OR p_priority > 3 THEN
            RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.support.invalid-priority';
        END IF;

        UPDATE support.tickets
        SET priority = p_priority, updated_at = NOW()
        WHERE id = p_ticket_id;

        INSERT INTO support.ticket_actions (
            ticket_id, action, performed_by_id, performed_by_type,
            action_data, created_at
        ) VALUES (
            p_ticket_id, 'PRIORITY_CHANGED', p_performed_by_id, 'BO_USER',
            jsonb_build_object('old', v_ticket.priority, 'new', p_priority),
            NOW()
        );
    END IF;

    -- Category güncelleme
    IF p_category_id IS NOT NULL AND (v_ticket.category_id IS NULL OR p_category_id <> v_ticket.category_id) THEN
        -- Kategori aktif mi?
        IF NOT EXISTS (SELECT 1 FROM support.ticket_categories WHERE id = p_category_id AND is_active = true) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.support.category-not-found';
        END IF;

        UPDATE support.tickets
        SET category_id = p_category_id, updated_at = NOW()
        WHERE id = p_ticket_id;

        INSERT INTO support.ticket_actions (
            ticket_id, action, performed_by_id, performed_by_type,
            action_data, created_at
        ) VALUES (
            p_ticket_id, 'CATEGORY_CHANGED', p_performed_by_id, 'BO_USER',
            jsonb_build_object('old', v_ticket.category_id, 'new', p_category_id),
            NOW()
        );
    END IF;
END;
$$;

COMMENT ON FUNCTION support.ticket_update IS 'Updates ticket priority and/or category. Each change creates a separate action log entry.';

-- ================================================================
-- TICKET_GET: Ticket detay (BO)
-- ================================================================
-- Ticket bilgisi + etiketler + aksiyon geçmişi döner.
-- Internal notlar dahil (BO görünümü).
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.ticket_get(BIGINT);

CREATE OR REPLACE FUNCTION support.ticket_get(
    p_ticket_id     BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_ticket    JSONB;
    v_tags      JSONB;
    v_actions   JSONB;
BEGIN
    -- Ticket bilgisi
    SELECT jsonb_build_object(
        'id', t.id,
        'playerId', t.player_id,
        'categoryId', t.category_id,
        'categoryName', tc.name,
        'channel', t.channel,
        'subject', t.subject,
        'description', t.description,
        'priority', t.priority,
        'status', t.status,
        'assignedToId', t.assigned_to_id,
        'assignedAt', t.assigned_at,
        'createdById', t.created_by_id,
        'createdByType', t.created_by_type,
        'resolvedById', t.resolved_by_id,
        'resolvedAt', t.resolved_at,
        'closedAt', t.closed_at,
        'createdAt', t.created_at,
        'updatedAt', t.updated_at
    ) INTO v_ticket
    FROM support.tickets t
    LEFT JOIN support.ticket_categories tc ON tc.id = t.category_id
    WHERE t.id = p_ticket_id;

    IF v_ticket IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.support.ticket-not-found';
    END IF;

    -- Etiketler
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', tg.id,
            'name', tg.name,
            'color', tg.color
        )
    ), '[]'::JSONB)
    INTO v_tags
    FROM support.ticket_tag_assignments tta
    JOIN support.ticket_tags tg ON tg.id = tta.tag_id
    WHERE tta.ticket_id = p_ticket_id
      AND tg.is_active = true;

    -- Aksiyon geçmişi (tüm aksiyonlar, internal dahil)
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', a.id,
            'action', a.action,
            'performedById', a.performed_by_id,
            'performedByType', a.performed_by_type,
            'oldStatus', a.old_status,
            'newStatus', a.new_status,
            'content', a.content,
            'isInternal', a.is_internal,
            'channel', a.channel,
            'actionData', a.action_data,
            'createdAt', a.created_at
        ) ORDER BY a.created_at ASC
    ), '[]'::JSONB)
    INTO v_actions
    FROM support.ticket_actions a
    WHERE a.ticket_id = p_ticket_id;

    RETURN v_ticket || jsonb_build_object(
        'tags', v_tags,
        'actions', v_actions
    );
END;
$$;

COMMENT ON FUNCTION support.ticket_get IS 'Returns full ticket details including category, tags, and complete action history. Internal notes are included (BO view).';

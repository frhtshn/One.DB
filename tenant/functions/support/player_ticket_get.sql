-- ================================================================
-- PLAYER_TICKET_GET: Oyuncu ticket detay
-- ================================================================
-- Oyuncunun kendi ticket'ının detayını döner.
-- Internal notlar (is_internal=true) filtrelenir.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.player_ticket_get(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION support.player_ticket_get(
    p_player_id     BIGINT,
    p_ticket_id     BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_ticket    JSONB;
    v_actions   JSONB;
BEGIN
    -- Ticket bilgisi + sahiplik kontrolü
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
        'createdAt', t.created_at,
        'updatedAt', t.updated_at,
        'resolvedAt', t.resolved_at,
        'closedAt', t.closed_at
    ) INTO v_ticket
    FROM support.tickets t
    LEFT JOIN support.ticket_categories tc ON tc.id = t.category_id
    WHERE t.id = p_ticket_id
      AND t.player_id = p_player_id;

    IF v_ticket IS NULL THEN
        -- Ticket var mı kontrol et (sahiplik vs bulunamadı ayrımı)
        IF EXISTS (SELECT 1 FROM support.tickets WHERE id = p_ticket_id) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.support.ticket-not-owner';
        ELSE
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.support.ticket-not-found';
        END IF;
    END IF;

    -- Aksiyonlar (internal notlar filtrelenir)
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', a.id,
            'action', a.action,
            'performedByType', a.performed_by_type,
            'content', a.content,
            'channel', a.channel,
            'createdAt', a.created_at
        ) ORDER BY a.created_at ASC
    ), '[]'::JSONB)
    INTO v_actions
    FROM support.ticket_actions a
    WHERE a.ticket_id = p_ticket_id
      AND a.is_internal = false;

    RETURN v_ticket || jsonb_build_object('actions', v_actions);
END;
$$;

COMMENT ON FUNCTION support.player_ticket_get IS 'Returns ticket details for the owning player. Internal notes (is_internal=true) are filtered out.';

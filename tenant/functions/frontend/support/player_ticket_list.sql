-- ================================================================
-- PLAYER_TICKET_LIST: Oyuncu ticket listesi
-- ================================================================
-- Oyuncunun kendi ticketlarını listeler.
-- Internal notlar filtrelenir, son yanıt zamanı eklenir.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.player_ticket_list(BIGINT, VARCHAR, INT, INT);

CREATE OR REPLACE FUNCTION support.player_ticket_list(
    p_player_id     BIGINT,
    p_status        VARCHAR(20) DEFAULT NULL,
    p_page          INT DEFAULT 1,
    p_page_size     INT DEFAULT 10
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_offset    INT;
    v_total     BIGINT;
    v_items     JSONB;
BEGIN
    v_offset := (GREATEST(p_page, 1) - 1) * p_page_size;

    -- Toplam sayı
    SELECT COUNT(*) INTO v_total
    FROM support.tickets t
    WHERE t.player_id = p_player_id
      AND (p_status IS NULL OR t.status = p_status);

    -- Sonuçları al
    SELECT COALESCE(jsonb_agg(sub.item), '[]'::JSONB)
    INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'id', t.id,
            'subject', t.subject,
            'channel', t.channel,
            'status', t.status,
            'priority', t.priority,
            'categoryName', tc.name,
            'createdAt', t.created_at,
            'lastReplyAt', (
                SELECT MAX(a.created_at)
                FROM support.ticket_actions a
                WHERE a.ticket_id = t.id
                  AND a.action = 'REPLIED_PLAYER'
                  AND a.is_internal = false
            ),
            'hasUnreadReply', EXISTS (
                SELECT 1
                FROM support.ticket_actions a
                WHERE a.ticket_id = t.id
                  AND a.action = 'REPLIED_PLAYER'
                  AND a.is_internal = false
                  AND a.created_at > COALESCE(
                      (SELECT MAX(a2.created_at) FROM support.ticket_actions a2
                       WHERE a2.ticket_id = t.id AND a2.performed_by_type = 'PLAYER'),
                      t.created_at
                  )
            )
        ) AS item
        FROM support.tickets t
        LEFT JOIN support.ticket_categories tc ON tc.id = t.category_id
        WHERE t.player_id = p_player_id
          AND (p_status IS NULL OR t.status = p_status)
        ORDER BY t.updated_at DESC
        LIMIT p_page_size
        OFFSET v_offset
    ) sub;

    RETURN jsonb_build_object(
        'items', v_items,
        'totalCount', v_total,
        'page', GREATEST(p_page, 1),
        'pageSize', p_page_size
    );
END;
$$;

COMMENT ON FUNCTION support.player_ticket_list IS 'Lists player own tickets with status filter. Internal notes are excluded. Includes last reply timestamp and unread indicator.';

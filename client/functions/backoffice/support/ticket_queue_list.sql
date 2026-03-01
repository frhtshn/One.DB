-- ================================================================
-- TICKET_QUEUE_LIST: Atanmamış ticket kuyruğu
-- ================================================================
-- Status open veya reopened olan ticketları öncelik sırasıyla listeler.
-- Call center dashboard'da kuyruk yönetimi için kullanılır.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.ticket_queue_list(INT, INT);

CREATE OR REPLACE FUNCTION support.ticket_queue_list(
    p_page      INT DEFAULT 1,
    p_page_size INT DEFAULT 20
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
    WHERE t.status IN ('open', 'reopened');

    -- Sonuçları al: öncelik DESC (urgent önce), sonra created_at ASC (eski önce)
    SELECT COALESCE(jsonb_agg(sub.item), '[]'::JSONB)
    INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'id', t.id,
            'playerId', t.player_id,
            'subject', t.subject,
            'channel', t.channel,
            'status', t.status,
            'priority', t.priority,
            'categoryId', t.category_id,
            'categoryName', tc.name,
            'createdByType', t.created_by_type,
            'createdAt', t.created_at,
            'updatedAt', t.updated_at
        ) AS item
        FROM support.tickets t
        LEFT JOIN support.ticket_categories tc ON t.category_id = tc.id
        WHERE t.status IN ('open', 'reopened')
        ORDER BY t.priority DESC, t.created_at ASC
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

COMMENT ON FUNCTION support.ticket_queue_list IS 'Lists unassigned tickets (open/reopened) for queue management. Sorted by priority DESC then creation date ASC.';

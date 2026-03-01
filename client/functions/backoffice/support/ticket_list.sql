-- ================================================================
-- TICKET_LIST: Ticket listesi (filtrelemeli + sayfalı, BO)
-- ================================================================
-- Status, kanal, öncelik, kategori, atanan temsilci, oyuncu,
-- metin arama ve tarih aralığı bazında filtreleme.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS support.ticket_list(VARCHAR, VARCHAR, SMALLINT, BIGINT, BIGINT, BIGINT, VARCHAR, TIMESTAMPTZ, TIMESTAMPTZ, INT, INT);

CREATE OR REPLACE FUNCTION support.ticket_list(
    p_status            VARCHAR(20) DEFAULT NULL,
    p_channel           VARCHAR(20) DEFAULT NULL,
    p_priority          SMALLINT DEFAULT NULL,
    p_category_id       BIGINT DEFAULT NULL,
    p_assigned_to_id    BIGINT DEFAULT NULL,
    p_player_id         BIGINT DEFAULT NULL,
    p_search            VARCHAR(255) DEFAULT NULL,
    p_date_from         TIMESTAMPTZ DEFAULT NULL,
    p_date_to           TIMESTAMPTZ DEFAULT NULL,
    p_page              INT DEFAULT 1,
    p_page_size         INT DEFAULT 20
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_offset    INT;
    v_total     BIGINT;
    v_items     JSONB;
    v_search    VARCHAR(255);
BEGIN
    v_offset := (GREATEST(p_page, 1) - 1) * p_page_size;
    v_search := CASE WHEN p_search IS NOT NULL AND TRIM(p_search) <> '' THEN '%' || TRIM(p_search) || '%' ELSE NULL END;

    -- Toplam sayı
    SELECT COUNT(*) INTO v_total
    FROM support.tickets t
    WHERE (p_status IS NULL OR t.status = p_status)
      AND (p_channel IS NULL OR t.channel = p_channel)
      AND (p_priority IS NULL OR t.priority = p_priority)
      AND (p_category_id IS NULL OR t.category_id = p_category_id)
      AND (p_assigned_to_id IS NULL OR t.assigned_to_id = p_assigned_to_id)
      AND (p_player_id IS NULL OR t.player_id = p_player_id)
      AND (v_search IS NULL OR t.subject ILIKE v_search)
      AND (p_date_from IS NULL OR t.created_at >= p_date_from)
      AND (p_date_to IS NULL OR t.created_at <= p_date_to);

    -- Sonuçları al
    SELECT COALESCE(jsonb_agg(sub.item), '[]'::JSONB)
    INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'id', t.id,
            'playerId', t.player_id,
            'categoryId', t.category_id,
            'categoryName', tc.name,
            'channel', t.channel,
            'subject', t.subject,
            'priority', t.priority,
            'status', t.status,
            'assignedToId', t.assigned_to_id,
            'assignedAt', t.assigned_at,
            'createdById', t.created_by_id,
            'createdByType', t.created_by_type,
            'createdAt', t.created_at,
            'updatedAt', t.updated_at
        ) AS item
        FROM support.tickets t
        LEFT JOIN support.ticket_categories tc ON tc.id = t.category_id
        WHERE (p_status IS NULL OR t.status = p_status)
          AND (p_channel IS NULL OR t.channel = p_channel)
          AND (p_priority IS NULL OR t.priority = p_priority)
          AND (p_category_id IS NULL OR t.category_id = p_category_id)
          AND (p_assigned_to_id IS NULL OR t.assigned_to_id = p_assigned_to_id)
          AND (p_player_id IS NULL OR t.player_id = p_player_id)
          AND (v_search IS NULL OR t.subject ILIKE v_search)
          AND (p_date_from IS NULL OR t.created_at >= p_date_from)
          AND (p_date_to IS NULL OR t.created_at <= p_date_to)
        ORDER BY t.created_at DESC
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

COMMENT ON FUNCTION support.ticket_list IS 'Lists tickets with optional filtering by status, channel, priority, category, assignee, player, text search, and date range. Paginated results.';

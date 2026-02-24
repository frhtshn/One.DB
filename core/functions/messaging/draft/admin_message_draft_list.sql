-- ================================================================
-- ADMIN_MESSAGE_DRAFT_LIST: Admin draft listesi (sayfalı)
-- Status ve tip filtreleri
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_message_draft_list(BIGINT, VARCHAR, VARCHAR, VARCHAR, INTEGER, INTEGER);
DROP FUNCTION IF EXISTS messaging.admin_message_draft_list(BIGINT, VARCHAR, VARCHAR, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION messaging.admin_message_draft_list(
    p_sender_id     BIGINT DEFAULT NULL,              -- Gönderen filtresi
    p_status        VARCHAR(20) DEFAULT NULL,         -- Status filtresi (draft/scheduled/published/cancelled)
    p_message_type  VARCHAR(30) DEFAULT NULL,         -- Tip filtresi
    p_offset        INTEGER DEFAULT 0,                -- Sayfalama başlangıcı
    p_limit         INTEGER DEFAULT 20                -- Sayfa boyutu
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_total INTEGER;
    v_items JSONB;
BEGIN
    -- Toplam kayıt sayısı
    SELECT count(*) INTO v_total
    FROM messaging.user_message_drafts d
    WHERE d.is_deleted = FALSE
      AND (p_sender_id IS NULL OR d.sender_id = p_sender_id)
      AND (p_status IS NULL OR d.status = p_status)
      AND (p_message_type IS NULL OR d.message_type = p_message_type);

    -- Sayfalı sonuçlar
    SELECT COALESCE(jsonb_agg(row_data), '[]'::JSONB) INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'id', d.id,
            'sender_id', d.sender_id,
            'sender_name', u.first_name || ' ' || u.last_name,
            'subject', d.subject,
            'message_type', d.message_type,
            'priority', d.priority,
            'status', d.status,
            'scheduled_at', d.scheduled_at,
            'published_at', d.published_at,
            'expires_at', d.expires_at,
            'total_recipients', d.total_recipients,
            'created_at', d.created_at
        ) AS row_data
        FROM messaging.user_message_drafts d
        LEFT JOIN security.users u ON u.id = d.sender_id
        WHERE d.is_deleted = FALSE
          AND (p_sender_id IS NULL OR d.sender_id = p_sender_id)
          AND (p_status IS NULL OR d.status = p_status)
          AND (p_message_type IS NULL OR d.message_type = p_message_type)
        ORDER BY d.created_at DESC
        OFFSET p_offset
        LIMIT p_limit
    ) sub;

    RETURN jsonb_build_object(
        'total', v_total,
        'offset', p_offset,
        'limit', p_limit,
        'items', v_items
    );
END;
$$;

COMMENT ON FUNCTION messaging.admin_message_draft_list(BIGINT, VARCHAR, VARCHAR, INTEGER, INTEGER) IS 'List message drafts with sender, status and type filters. Returns paginated results with total count.';

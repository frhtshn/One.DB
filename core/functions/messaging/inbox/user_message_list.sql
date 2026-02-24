-- ================================================================
-- USER_MESSAGE_LIST: Kullanıcı inbox listesi
-- Okundu/okunmadı ve öncelik filtreleri
-- Süresi dolmuş mesajlar hariç tutulur
-- Sayfalama, toplam ve okunmamış sayısı dahil
-- ================================================================

DROP FUNCTION IF EXISTS messaging.user_message_list(BIGINT, BOOLEAN, VARCHAR, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION messaging.user_message_list(
    p_user_id   BIGINT,                        -- Kullanıcı ID
    p_is_read   BOOLEAN DEFAULT NULL,          -- Okundu filtresi (NULL = tümü)
    p_priority  VARCHAR(10) DEFAULT NULL,      -- Öncelik filtresi
    p_offset    INTEGER DEFAULT 0,             -- Sayfalama başlangıcı
    p_limit     INTEGER DEFAULT 20             -- Sayfa boyutu
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_total INTEGER;
    v_unread_count INTEGER;
    v_items JSONB;
BEGIN
    IF p_user_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.user-id-required' USING ERRCODE = 'P0400';
    END IF;

    -- Okunmamış sayısı
    SELECT count(*) INTO v_unread_count
    FROM messaging.user_messages m
    WHERE m.recipient_id = p_user_id
      AND m.is_deleted = FALSE
      AND m.is_read = FALSE
      AND (m.expires_at IS NULL OR m.expires_at > NOW());

    -- Toplam kayıt sayısı (filtreli)
    SELECT count(*) INTO v_total
    FROM messaging.user_messages m
    WHERE m.recipient_id = p_user_id
      AND m.is_deleted = FALSE
      AND (m.expires_at IS NULL OR m.expires_at > NOW())
      AND (p_is_read IS NULL OR m.is_read = p_is_read)
      AND (p_priority IS NULL OR m.priority = p_priority);

    -- Sayfalı sonuçlar
    SELECT COALESCE(jsonb_agg(row_data), '[]'::JSONB) INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'id', m.id,
            'sender_id', m.sender_id,
            'sender_name', u.first_name || ' ' || u.last_name,
            'subject', m.subject,
            'body', m.body,
            'message_type', m.message_type,
            'priority', m.priority,
            'is_read', m.is_read,
            'read_at', m.read_at,
            'draft_id', m.draft_id,
            'expires_at', m.expires_at,
            'created_at', m.created_at
        ) AS row_data
        FROM messaging.user_messages m
        LEFT JOIN security.users u ON u.id = m.sender_id
        WHERE m.recipient_id = p_user_id
          AND m.is_deleted = FALSE
          AND (m.expires_at IS NULL OR m.expires_at > NOW())
          AND (p_is_read IS NULL OR m.is_read = p_is_read)
          AND (p_priority IS NULL OR m.priority = p_priority)
        ORDER BY m.created_at DESC
        OFFSET p_offset
        LIMIT p_limit
    ) sub;

    RETURN jsonb_build_object(
        'total', v_total,
        'unread_count', v_unread_count,
        'offset', p_offset,
        'limit', p_limit,
        'items', v_items
    );
END;
$$;

COMMENT ON FUNCTION messaging.user_message_list(BIGINT, BOOLEAN, VARCHAR, INTEGER, INTEGER) IS 'List user inbox messages with read/unread and priority filters. Returns paginated results with total and unread counts. Excludes expired messages.';

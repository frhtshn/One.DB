-- ================================================================
-- PLAYER_MESSAGE_LIST: Oyuncu mesaj kutusunu listele
-- Silinmemiş mesajları tarih sırasına göre getirir
-- Okunma durumuna göre filtreleme desteği
-- Okunmamış sayısı da döner
-- ================================================================

DROP FUNCTION IF EXISTS messaging.player_message_list(BIGINT, BOOLEAN, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION messaging.player_message_list(
    p_player_id         BIGINT,             -- Oyuncu ID
    p_is_read           BOOLEAN DEFAULT NULL, -- NULL = tümü, TRUE = okunmuş, FALSE = okunmamış
    p_offset            INTEGER DEFAULT 0,    -- Sayfalama: başlangıç
    p_limit             INTEGER DEFAULT 20    -- Sayfalama: sayfa boyutu
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_total_count  INTEGER;
    v_unread_count INTEGER;
    v_items        JSONB;
BEGIN
    -- Parametre doğrulama
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.player-id-required';
    END IF;

    -- Okunmamış sayısı
    SELECT COUNT(*) INTO v_unread_count
    FROM messaging.player_messages
    WHERE player_id = p_player_id AND is_read = FALSE AND is_deleted = FALSE;

    -- Toplam sayı (filtreye göre)
    SELECT COUNT(*) INTO v_total_count
    FROM messaging.player_messages
    WHERE player_id = p_player_id
      AND is_deleted = FALSE
      AND (p_is_read IS NULL OR is_read = p_is_read);

    -- Sayfalanmış liste
    SELECT COALESCE(jsonb_agg(row_data ORDER BY created_at DESC), '[]'::JSONB)
    INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'id', m.id,
            'subject', m.subject,
            'body', m.body,
            'message_type', m.message_type,
            'is_read', m.is_read,
            'read_at', m.read_at,
            'created_at', m.created_at
        ) AS row_data,
        m.created_at
        FROM messaging.player_messages m
        WHERE m.player_id = p_player_id
          AND m.is_deleted = FALSE
          AND (p_is_read IS NULL OR m.is_read = p_is_read)
        ORDER BY m.created_at DESC
        OFFSET p_offset
        LIMIT p_limit
    ) sub;

    RETURN jsonb_build_object(
        'items', v_items,
        'total_count', v_total_count,
        'unread_count', v_unread_count
    );
END;
$$;

COMMENT ON FUNCTION messaging.player_message_list(BIGINT, BOOLEAN, INTEGER, INTEGER) IS 'List player inbox messages with read/unread filter. Returns paginated results with total and unread counts.';

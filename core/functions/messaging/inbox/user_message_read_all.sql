-- ================================================================
-- USER_MESSAGE_READ_ALL: Tüm unread mesajları okundu yapar
-- Batch read-all operasyonu
-- ================================================================

CREATE OR REPLACE FUNCTION messaging.user_message_read_all(
    p_user_id BIGINT  -- Kullanıcı ID (alıcı)
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_count INTEGER;
BEGIN
    IF p_user_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.user-id-required' USING ERRCODE = 'P0400';
    END IF;

    UPDATE messaging.user_messages
    SET is_read = TRUE,
        read_at = NOW()
    WHERE recipient_id = p_user_id
      AND NOT is_read
      AND NOT is_deleted
      AND (expires_at IS NULL OR expires_at > NOW());

    GET DIAGNOSTICS v_count = ROW_COUNT;

    RETURN v_count;
END;
$$;

COMMENT ON FUNCTION messaging.user_message_read_all(BIGINT) IS 'Mark all unread messages as read for a user. Returns number of affected messages. Excludes expired and deleted messages.';

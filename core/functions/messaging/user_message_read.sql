-- ================================================================
-- USER_MESSAGE_READ: Mesajı okundu olarak işaretler
-- Sadece alıcı kendi mesajlarını işaretleyebilir
-- Broadcast mesajlarında read_count güncellenir
-- ================================================================

DROP FUNCTION IF EXISTS messaging.user_message_read(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION messaging.user_message_read(
    p_user_id    BIGINT,  -- Kullanıcı ID (alıcı)
    p_message_id BIGINT   -- Mesaj ID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_broadcast_id INTEGER;
    v_updated BOOLEAN;
BEGIN
    IF p_user_id IS NULL OR p_message_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.invalid-parameters';
    END IF;

    -- Mesajı okundu işaretle ve broadcast_id'yi al
    UPDATE messaging.user_messages
    SET is_read = TRUE,
        read_at = NOW()
    WHERE recipient_id = p_user_id
      AND id = p_message_id
      AND is_read = FALSE
      AND is_deleted = FALSE
    RETURNING broadcast_id INTO v_broadcast_id;

    GET DIAGNOSTICS v_updated = ROW_COUNT;

    -- Broadcast mesajıysa read_count güncelle
    IF v_updated > 0 AND v_broadcast_id IS NOT NULL THEN
        UPDATE messaging.user_message_broadcasts
        SET read_count = read_count + 1
        WHERE id = v_broadcast_id;
    END IF;

    RETURN v_updated > 0;
END;
$$;

COMMENT ON FUNCTION messaging.user_message_read(BIGINT, BIGINT) IS 'Mark a user message as read. Only the owning user can mark their messages. Updates broadcast read_count for broadcast messages.';

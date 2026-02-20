-- ================================================================
-- USER_MESSAGE_READ: Mesajı okundu olarak işaretler
-- Sadece alıcı kendi mesajlarını işaretleyebilir
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
    v_updated INTEGER;
BEGIN
    IF p_user_id IS NULL OR p_message_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.invalid-parameters' USING ERRCODE = 'P0400';
    END IF;

    -- Mesajı okundu işaretle
    UPDATE messaging.user_messages
    SET is_read = TRUE,
        read_at = NOW()
    WHERE recipient_id = p_user_id
      AND id = p_message_id
      AND is_read = FALSE
      AND is_deleted = FALSE;

    GET DIAGNOSTICS v_updated = ROW_COUNT;

    RETURN v_updated > 0;
END;
$$;

COMMENT ON FUNCTION messaging.user_message_read(BIGINT, BIGINT) IS 'Mark a user message as read. Only the recipient can mark their own messages.';

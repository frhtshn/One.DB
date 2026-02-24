-- ================================================================
-- USER_MESSAGE_UNREAD_COUNT: Kullanıcının okunmamış mesaj sayısını döner
-- Hafif endpoint: cache'lenmez, sadece ilk yükleme ve reconnect'te çağrılır
-- ================================================================

DROP FUNCTION IF EXISTS messaging.user_message_unread_count(BIGINT);

CREATE OR REPLACE FUNCTION messaging.user_message_unread_count(
    p_user_id BIGINT
)
RETURNS INTEGER
AS $$
DECLARE
    v_count INTEGER;
BEGIN
    IF p_user_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.user-id-required' USING ERRCODE = 'P0400';
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM messaging.user_messages
    WHERE recipient_id = p_user_id
      AND is_deleted = FALSE
      AND is_read = FALSE
      AND (expires_at IS NULL OR expires_at > NOW());

    RETURN v_count;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION messaging.user_message_unread_count(BIGINT) IS 'Returns unread message count for a user. Excludes deleted and expired messages.';

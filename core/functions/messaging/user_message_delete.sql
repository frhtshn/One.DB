-- ================================================================
-- USER_MESSAGE_DELETE: Mesajı kullanıcı inbox'ından soft delete yapar
-- Sadece alıcı kendi mesajlarını silebilir
-- Veri denetim amaçlı korunur
-- ================================================================

DROP FUNCTION IF EXISTS messaging.user_message_delete(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION messaging.user_message_delete(
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

    UPDATE messaging.user_messages
    SET is_deleted = TRUE,
        deleted_at = NOW()
    WHERE recipient_id = p_user_id
      AND id = p_message_id
      AND is_deleted = FALSE;

    GET DIAGNOSTICS v_updated = ROW_COUNT;

    RETURN v_updated > 0;
END;
$$;

COMMENT ON FUNCTION messaging.user_message_delete(BIGINT, BIGINT) IS 'Soft delete a user message from inbox. Only the owning user can delete their messages. Data is preserved for audit.';

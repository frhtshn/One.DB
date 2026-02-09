-- ================================================================
-- PLAYER_MESSAGE_READ: Mesajı okundu olarak işaretle
-- Oyuncu sadece kendi mesajlarını okuyabilir
-- Zaten okunmuş mesaj tekrar güncellemez
-- ================================================================

DROP FUNCTION IF EXISTS messaging.player_message_read(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION messaging.player_message_read(
    p_player_id         BIGINT,             -- Oyuncu ID
    p_message_id        BIGINT              -- Mesaj ID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
BEGIN
    -- Mesaj varlık ve sahiplik kontrolü
    IF NOT EXISTS (
        SELECT 1 FROM messaging.player_messages
        WHERE id = p_message_id AND player_id = p_player_id AND is_deleted = FALSE
    ) THEN
        RAISE EXCEPTION 'error.messaging.message-not-found';
    END IF;

    -- Okundu olarak işaretle (zaten okunmuşsa güncelleme yapılmaz)
    UPDATE messaging.player_messages SET
        is_read = TRUE,
        read_at = now()
    WHERE id = p_message_id
      AND player_id = p_player_id
      AND is_read = FALSE;

    RETURN TRUE;
END;
$$;

COMMENT ON FUNCTION messaging.player_message_read(BIGINT, BIGINT) IS 'Mark a player message as read. Only the owning player can mark their messages.';

-- ================================================================
-- PLAYER_MESSAGE_DELETE: Mesajı oyuncu perspektifinden sil
-- Soft delete: is_deleted = TRUE, deleted_at = now()
-- Oyuncu sadece kendi mesajlarını silebilir
-- Veritabanından kalıcı olarak silinmez
-- ================================================================

DROP FUNCTION IF EXISTS messaging.player_message_delete(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION messaging.player_message_delete(
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

    -- Soft delete
    UPDATE messaging.player_messages SET
        is_deleted = TRUE,
        deleted_at = now()
    WHERE id = p_message_id
      AND player_id = p_player_id;

    RETURN TRUE;
END;
$$;

COMMENT ON FUNCTION messaging.player_message_delete(BIGINT, BIGINT) IS 'Soft delete a player message from inbox. Only the owning player can delete their messages. Data is preserved for audit.';

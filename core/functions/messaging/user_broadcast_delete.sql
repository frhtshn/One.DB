-- ================================================================
-- USER_BROADCAST_DELETE: Broadcast kaydını soft delete yapar
-- Broadcast silinir ama user_messages'taki mesajlar kalır
-- Kullanıcılar mesajlarını kendi inbox'larından bağımsız siler
-- ================================================================

DROP FUNCTION IF EXISTS messaging.user_broadcast_delete(INTEGER, BIGINT);

CREATE OR REPLACE FUNCTION messaging.user_broadcast_delete(
    p_broadcast_id INTEGER,  -- Silinecek broadcast ID
    p_deleted_by   BIGINT    -- Silen kullanıcı ID
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_updated BOOLEAN;
BEGIN
    IF p_broadcast_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.broadcast-id-required';
    END IF;

    UPDATE messaging.user_message_broadcasts
    SET is_deleted = TRUE,
        deleted_at = NOW()
    WHERE id = p_broadcast_id
      AND is_deleted = FALSE;

    GET DIAGNOSTICS v_updated = ROW_COUNT;

    RETURN v_updated > 0;
END;
$$;

COMMENT ON FUNCTION messaging.user_broadcast_delete(INTEGER, BIGINT) IS 'Soft delete a broadcast record. Individual user messages remain in recipients inboxes.';

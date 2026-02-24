-- ================================================================
-- USER_MESSAGE_GET_BY_IDS: Batch mesaj detayı (reconnect için)
-- Redis pending SET'teki messageId'ler ile DB'den mesaj çeker
-- Expired ve deleted mesajlar hariç tutulur
-- ================================================================

CREATE OR REPLACE FUNCTION messaging.user_message_get_by_ids(
    p_user_id     BIGINT,     -- Kullanıcı ID (alıcı)
    p_message_ids BIGINT[]    -- Mesaj ID dizisi
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (
        SELECT COALESCE(
            jsonb_agg(jsonb_build_object(
                'id', m.id,
                'draft_id', m.draft_id,
                'subject', m.subject,
                'body', m.body,
                'message_type', m.message_type,
                'priority', m.priority,
                'sender_id', m.sender_id,
                'sender_name', u.first_name || ' ' || u.last_name,
                'is_read', m.is_read,
                'created_at', m.created_at,
                'expires_at', m.expires_at
            )),
            '[]'::JSONB
        )
        FROM messaging.user_messages m
        LEFT JOIN security.users u ON u.id = m.sender_id
        WHERE m.recipient_id = p_user_id
          AND m.id = ANY(p_message_ids)
          AND NOT m.is_deleted
          AND (m.expires_at IS NULL OR m.expires_at > NOW())
    );
END;
$$;

COMMENT ON FUNCTION messaging.user_message_get_by_ids(BIGINT, BIGINT[]) IS 'Batch fetch message details by IDs for a user. Used by GetPendingNotifications on reconnect. Excludes expired and deleted messages.';

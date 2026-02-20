-- ================================================================
-- GET_PUBLISHED_RECIPIENTS: Publish sonrası recipient + messageId listesi
-- Fan-out handler tarafından kullanılır
-- ================================================================

DROP FUNCTION IF EXISTS messaging.get_published_recipients(INTEGER);

CREATE OR REPLACE FUNCTION messaging.get_published_recipients(
    p_draft_id INTEGER  -- Draft ID
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (
        SELECT COALESCE(
            jsonb_agg(jsonb_build_object(
                'message_id', id,
                'recipient_id', recipient_id
            )),
            '[]'::JSONB
        )
        FROM messaging.user_messages
        WHERE draft_id = p_draft_id
          AND NOT is_deleted
    );
END;
$$;

COMMENT ON FUNCTION messaging.get_published_recipients(INTEGER) IS 'Get recipient list with message IDs for a published draft. Used by fan-out handler for SignalR push delivery.';

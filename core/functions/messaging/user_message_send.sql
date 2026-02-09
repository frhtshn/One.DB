-- ================================================================
-- USER_MESSAGE_SEND: Tek kullanıcıya doğrudan mesaj gönderir
-- Broadcast altyapısı gerektirmez (broadcast_id = NULL)
-- Admin → User birebir mesaj senaryosu
-- ================================================================

DROP FUNCTION IF EXISTS messaging.user_message_send(BIGINT, BIGINT, VARCHAR, TEXT, VARCHAR, VARCHAR, TIMESTAMP);

CREATE OR REPLACE FUNCTION messaging.user_message_send(
    p_sender_id     BIGINT,                      -- Gönderen kullanıcı ID
    p_recipient_id  BIGINT,                      -- Alıcı kullanıcı ID
    p_subject       VARCHAR(500),                -- Mesaj konusu
    p_body          TEXT,                         -- Mesaj içeriği (HTML)
    p_message_type  VARCHAR(30) DEFAULT 'direct', -- Mesaj tipi
    p_priority      VARCHAR(10) DEFAULT 'normal', -- Öncelik seviyesi
    p_expires_at    TIMESTAMP DEFAULT NULL        -- Opsiyonel süre sonu
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_message_id BIGINT;
BEGIN
    -- Zorunlu alan kontrolleri
    IF p_sender_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.sender-id-required';
    END IF;

    IF p_recipient_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.recipient-id-required';
    END IF;

    IF p_subject IS NULL OR p_subject = '' THEN
        RAISE EXCEPTION 'error.messaging.subject-required';
    END IF;

    IF p_body IS NULL OR p_body = '' THEN
        RAISE EXCEPTION 'error.messaging.body-required';
    END IF;

    -- Mesaj oluştur
    INSERT INTO messaging.user_messages (
        recipient_id, sender_id, subject, body,
        message_type, priority, expires_at
    ) VALUES (
        p_recipient_id, p_sender_id, p_subject, p_body,
        p_message_type, p_priority, p_expires_at
    )
    RETURNING id INTO v_message_id;

    RETURN v_message_id;
END;
$$;

COMMENT ON FUNCTION messaging.user_message_send(BIGINT, BIGINT, VARCHAR, TEXT, VARCHAR, VARCHAR, TIMESTAMP) IS 'Send a direct message to a single user inbox. No broadcast infrastructure required.';

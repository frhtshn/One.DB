-- ================================================================
-- ADMIN_MESSAGE_SEND: Tek kullanıcıya doğrudan mesaj gönderir
-- Admin → User birebir mesaj senaryosu
-- Kendine gönderim engeli ve alıcı varlık/aktiflik kontrolü var
-- Sender scope kontrolü: alıcının company'sine erişim doğrulaması
-- ================================================================

DROP FUNCTION IF EXISTS messaging.admin_message_send(BIGINT, BIGINT, VARCHAR, TEXT, VARCHAR, VARCHAR, TIMESTAMP);

CREATE OR REPLACE FUNCTION messaging.admin_message_send(
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
    v_recipient_company_id BIGINT;
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

    -- Kendine mesaj gönderim engeli
    IF p_sender_id = p_recipient_id THEN
        RAISE EXCEPTION 'error.messaging.cannot-send-to-self';
    END IF;

    -- Alıcı varlık ve aktiflik kontrolü + company bilgisini al
    SELECT company_id INTO v_recipient_company_id
    FROM security.users
    WHERE id = p_recipient_id AND status = 1;

    IF v_recipient_company_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.recipient-not-found';
    END IF;

    -- Scope kontrolü: sender alıcının company'sine erişebilir mi?
    PERFORM security.user_assert_access_company(p_sender_id, v_recipient_company_id);

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

COMMENT ON FUNCTION messaging.admin_message_send(BIGINT, BIGINT, VARCHAR, TEXT, VARCHAR, VARCHAR, TIMESTAMP) IS 'Send a direct message to a single user inbox. Validates recipient exists/active, prevents self-messaging, and validates sender access to recipient company scope.';

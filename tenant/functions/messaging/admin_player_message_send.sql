-- ================================================================
-- PLAYER_MESSAGE_SEND: Oyuncuya tekil mesaj gönderme
-- Sistem otomatik mesajları (transaction, kyc, welcome vb.)
-- veya BO kullanıcı tarafından manuel gönderim
-- Kampanya altyapısı gerektirmez, doğrudan player_messages'a yazar
-- ================================================================

DROP FUNCTION IF EXISTS messaging.player_message_send(BIGINT, VARCHAR, TEXT, VARCHAR, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION messaging.player_message_send(
    p_player_id         BIGINT,                 -- Hedef oyuncu ID
    p_subject           VARCHAR(500),            -- Mesaj konusu
    p_body              TEXT,                     -- Mesaj içeriği (HTML)
    p_message_type      VARCHAR(30) DEFAULT 'system', -- Mesaj tipi: system, welcome, kyc, transaction, manual
    p_campaign_id       INTEGER DEFAULT NULL,    -- Bağlı kampanya (opsiyonel)
    p_created_by        INTEGER DEFAULT NULL     -- Gönderen BO kullanıcı (NULL = sistem)
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_message_id BIGINT;
BEGIN
    -- Parametre doğrulama
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION 'error.messaging.player-id-required';
    END IF;

    IF p_subject IS NULL OR p_subject = '' THEN
        RAISE EXCEPTION 'error.messaging.subject-required';
    END IF;

    IF p_body IS NULL OR p_body = '' THEN
        RAISE EXCEPTION 'error.messaging.body-required';
    END IF;

    IF p_message_type NOT IN ('system', 'welcome', 'kyc', 'transaction', 'manual', 'campaign') THEN
        RAISE EXCEPTION 'error.messaging.invalid-message-type';
    END IF;

    -- Mesajı oyuncu inbox'ına yaz
    INSERT INTO messaging.player_messages (
        player_id, campaign_id, subject, body, message_type
    ) VALUES (
        p_player_id, p_campaign_id, p_subject, p_body, p_message_type
    )
    RETURNING id INTO v_message_id;

    RETURN v_message_id;
END;
$$;

COMMENT ON FUNCTION messaging.player_message_send(BIGINT, VARCHAR, TEXT, VARCHAR, INTEGER, INTEGER) IS 'Send a single message to a player inbox. Used by system services (automated notifications) and BO users (manual direct messages).';

-- =============================================
-- Tablo: support_log.ticket_activity_logs
-- Açıklama: Ticket bildirim gönderim logları.
--           Ticket güncellemelerinde oyuncuya/
--           temsilciye gönderilen bildirimler.
-- CLIENT_LOG DB - 90 gün retention
-- Günlük partition (created_at)
-- =============================================

DROP TABLE IF EXISTS support_log.ticket_activity_logs CASCADE;

CREATE TABLE support_log.ticket_activity_logs (
    id                  BIGSERIAL,
    ticket_id           BIGINT          NOT NULL,               -- İlgili ticket
    notification_type   VARCHAR(30)     NOT NULL,               -- ticket_created, ticket_assigned, ticket_replied, ticket_resolved, ticket_closed
    channel             VARCHAR(20)     NOT NULL,               -- Gönderim kanalı: email, sms, push, internal
    recipient_id        BIGINT          NOT NULL,               -- Alıcı (player_id veya user_id)
    recipient_type      VARCHAR(10)     NOT NULL,               -- PLAYER veya BO_USER
    status              VARCHAR(20)     NOT NULL DEFAULT 'pending', -- pending, sent, failed
    error_message       TEXT,                                   -- Hata mesajı (failed için)
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    sent_at             TIMESTAMPTZ,                            -- Gönderim zamanı
    PRIMARY KEY (id, created_at)                                -- Partition key PK'ya dahil
) PARTITION BY RANGE (created_at);

CREATE TABLE support_log.ticket_activity_logs_default PARTITION OF support_log.ticket_activity_logs DEFAULT;

COMMENT ON TABLE support_log.ticket_activity_logs IS 'Daily-partitioned log of ticket notification delivery attempts. Tracks email/SMS/push notifications sent for ticket events. Retention: 90 days.';

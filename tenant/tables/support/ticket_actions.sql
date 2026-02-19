-- =============================================
-- Tablo: support.ticket_actions
-- Açıklama: Ticket aksiyonlarının değişmez
--           (immutable) logu. Her durum değişikliği,
--           yanıt ve operatör eylemi kayıt altına
--           alınır. bonus_request_actions pattern'i.
-- =============================================

DROP TABLE IF EXISTS support.ticket_actions CASCADE;

CREATE TABLE support.ticket_actions (
    id                  BIGSERIAL       PRIMARY KEY,
    ticket_id           BIGINT          NOT NULL,               -- FK → tickets.id
    action              VARCHAR(30)     NOT NULL,               -- CREATED, ASSIGNED, REASSIGNED, UNASSIGNED, STARTED, PENDING_PLAYER, REPLIED_INTERNAL, REPLIED_PLAYER, PLAYER_REPLIED, RESOLVED, CLOSED, REOPENED, CANCELLED, PRIORITY_CHANGED, CATEGORY_CHANGED, TAG_ADDED, TAG_REMOVED
    performed_by_id     BIGINT,                                 -- Eylemi yapan (player_id veya user_id)
    performed_by_type   VARCHAR(10)     NOT NULL,               -- PLAYER, BO_USER, SYSTEM
    old_status          VARCHAR(20),                            -- Önceki durum (status değişikliği için)
    new_status          VARCHAR(20),                            -- Yeni durum
    content             TEXT,                                   -- Not, yanıt metni veya açıklama
    is_internal         BOOLEAN         NOT NULL DEFAULT false, -- Internal not mu? (oyuncuya gösterilmez)
    channel             VARCHAR(20),                            -- Yanıtın kanalı (opsiyonel)
    action_data         JSONB,                                  -- Ek veri (eski/yeni değerler vb.)
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE support.ticket_actions IS 'Immutable action log for support tickets. Every status change, reply, and operator action is recorded for full audit trail.';

-- =============================================
-- Tablo: bonus.bonus_request_actions
-- Açıklama: Bonus talep aksiyonlarının değişmez
--           (immutable) logu. Her durum değişikliği
--           ve operatör eylemi kayıt altına alınır.
--           transaction_workflow_actions ile
--           aynı pattern.
-- =============================================

DROP TABLE IF EXISTS bonus.bonus_request_actions CASCADE;

CREATE TABLE bonus.bonus_request_actions (
    id                  BIGSERIAL       PRIMARY KEY,
    request_id          BIGINT          NOT NULL,               -- FK → bonus_requests.id
    action              VARCHAR(30)     NOT NULL,               -- CREATED, ASSIGNED, REVIEW_STARTED, ON_HOLD, RESUMED, APPROVED, REJECTED, CANCELLED, EXPIRED, NOTE_ADDED, AMOUNT_ADJUSTED, COMPLETED, FAILED, ROLLBACK
    performed_by_id     BIGINT,                                 -- Eylemi yapan (player_id veya user_id)
    performed_by_type   VARCHAR(20)     NOT NULL,               -- PLAYER, BO_USER, SYSTEM
    note                VARCHAR(500),                           -- Eylem notu / açıklama
    action_data         JSONB,                                  -- Ek veri (eski/yeni değerler vb.)
    created_at          TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE bonus.bonus_request_actions IS 'Immutable action log for bonus requests. Every status change and operator action is recorded for full audit trail.';

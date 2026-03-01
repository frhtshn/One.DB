-- =============================================
-- Transaction Workflow Actions (İş Akışı Hareketleri)
-- Workflow üzerinde yapılan tüm işlemler
-- Onay, red, atama, not ekleme vb.
-- =============================================

DROP TABLE IF EXISTS transaction.transaction_workflow_actions CASCADE;

CREATE TABLE transaction.transaction_workflow_actions (
    id bigserial PRIMARY KEY,
    workflow_id bigint NOT NULL,                  -- Bağlı workflow ID
    action varchar(30) NOT NULL,                  -- Eylem: APPROVE, REJECT, ASSIGN, NOTE, ESCALATE
    performed_by_id bigint,                       -- İşlemi yapan ID
    performed_by_type varchar(30) NOT NULL,       -- İşlemi yapan tipi: BO_USER, SYSTEM, PLAYER
    note varchar(255),                            -- Açıklama/not
    created_at timestamp without time zone NOT NULL DEFAULT now()
);

COMMENT ON TABLE transaction.transaction_workflow_actions IS 'Workflow action history tracking approvals, rejections, assignments, and escalations';

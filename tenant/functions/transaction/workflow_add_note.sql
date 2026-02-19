-- ================================================================
-- WORKFLOW_ADD_NOTE: Workflow'a not ekle
-- ================================================================
-- Herhangi bir durumdaki workflow'a not ekler.
-- Durumu değiştirmez, sadece action geçmişine kayıt ekler.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS transaction.workflow_add_note(BIGINT, VARCHAR, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION transaction.workflow_add_note(
    p_workflow_id           BIGINT,
    p_note                  VARCHAR(255),
    p_performed_by_id       BIGINT,
    p_performed_by_type     VARCHAR(30)     DEFAULT 'BO_USER'
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    -- Workflow varlık kontrolü
    IF NOT EXISTS (SELECT 1 FROM transaction.transaction_workflows WHERE id = p_workflow_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.workflow.not-found';
    END IF;

    -- Action kaydı
    INSERT INTO transaction.transaction_workflow_actions (
        workflow_id, action, performed_by_id, performed_by_type,
        note, created_at
    ) VALUES (
        p_workflow_id, 'NOTE', p_performed_by_id, p_performed_by_type,
        p_note, NOW()
    );
END;
$$;

COMMENT ON FUNCTION transaction.workflow_add_note IS 'Adds a note to a workflow without changing its status. Supports any workflow state.';

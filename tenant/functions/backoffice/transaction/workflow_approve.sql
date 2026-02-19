-- ================================================================
-- WORKFLOW_APPROVE: Workflow'u onayla
-- ================================================================
-- IN_REVIEW durumundaki workflow'u onaylar. Backend sonraki
-- adımı çağırır (withdrawal_confirm, adjustment_apply vb.).
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS transaction.workflow_approve(BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION transaction.workflow_approve(
    p_workflow_id       BIGINT,
    p_approved_by_id    BIGINT,
    p_note              VARCHAR(255)    DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_workflow RECORD;
BEGIN
    -- Workflow bul
    SELECT id, transaction_id, workflow_type, status
    INTO v_workflow
    FROM transaction.transaction_workflows
    WHERE id = p_workflow_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.workflow.not-found';
    END IF;

    -- Durum kontrolü: IN_REVIEW olmalı
    IF v_workflow.status != 'IN_REVIEW' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.workflow.not-in-review';
    END IF;

    -- Workflow güncelle
    UPDATE transaction.transaction_workflows SET
        status = 'APPROVED',
        updated_at = NOW()
    WHERE id = p_workflow_id;

    -- Action kaydı
    INSERT INTO transaction.transaction_workflow_actions (
        workflow_id, action, performed_by_id, performed_by_type,
        note, created_at
    ) VALUES (
        p_workflow_id, 'APPROVE', p_approved_by_id, 'BO_USER',
        p_note, NOW()
    );

    RETURN jsonb_build_object(
        'workflowId', p_workflow_id,
        'transactionId', v_workflow.transaction_id,
        'status', 'APPROVED',
        'workflowType', v_workflow.workflow_type
    );
END;
$$;

COMMENT ON FUNCTION transaction.workflow_approve IS 'Approves a workflow in IN_REVIEW status. Backend must call the appropriate follow-up action (e.g. withdrawal_confirm, adjustment_apply).';

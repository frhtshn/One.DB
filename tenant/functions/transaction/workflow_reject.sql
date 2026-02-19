-- ================================================================
-- WORKFLOW_REJECT: Workflow'u reddet
-- ================================================================
-- IN_REVIEW durumundaki workflow'u reddeder. Backend sonraki
-- adımı çağırır (withdrawal_cancel, adjustment_cancel vb.).
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS transaction.workflow_reject(BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION transaction.workflow_reject(
    p_workflow_id       BIGINT,
    p_rejected_by_id    BIGINT,
    p_reason            VARCHAR(255)
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
        status = 'REJECTED',
        reason = p_reason,
        updated_at = NOW()
    WHERE id = p_workflow_id;

    -- Action kaydı
    INSERT INTO transaction.transaction_workflow_actions (
        workflow_id, action, performed_by_id, performed_by_type,
        note, created_at
    ) VALUES (
        p_workflow_id, 'REJECT', p_rejected_by_id, 'BO_USER',
        p_reason, NOW()
    );

    RETURN jsonb_build_object(
        'workflowId', p_workflow_id,
        'transactionId', v_workflow.transaction_id,
        'status', 'REJECTED',
        'workflowType', v_workflow.workflow_type
    );
END;
$$;

COMMENT ON FUNCTION transaction.workflow_reject IS 'Rejects a workflow in IN_REVIEW status with mandatory reason. Backend must call the appropriate cancellation action.';

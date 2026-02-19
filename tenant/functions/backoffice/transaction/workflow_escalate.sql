-- ================================================================
-- WORKFLOW_ESCALATE: Workflow'u üst seviyeye yükselt
-- ================================================================
-- IN_REVIEW durumundaki workflow'u başka bir BO kullanıcısına
-- yönlendirir. Status IN_REVIEW kalır, assigned_to_id değişir.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS transaction.workflow_escalate(BIGINT, BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION transaction.workflow_escalate(
    p_workflow_id       BIGINT,
    p_escalated_to_id   BIGINT,
    p_escalated_by_id   BIGINT,
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

    -- Workflow güncelle (status kalır, assigned_to değişir)
    UPDATE transaction.transaction_workflows SET
        assigned_to_id = p_escalated_to_id,
        updated_at = NOW()
    WHERE id = p_workflow_id;

    -- Action kaydı
    INSERT INTO transaction.transaction_workflow_actions (
        workflow_id, action, performed_by_id, performed_by_type,
        note, created_at
    ) VALUES (
        p_workflow_id, 'ESCALATE', p_escalated_by_id, 'BO_USER',
        COALESCE(p_note, 'Escalated to user ID: ' || p_escalated_to_id), NOW()
    );

    RETURN jsonb_build_object(
        'workflowId', p_workflow_id,
        'status', 'IN_REVIEW',
        'assignedToId', p_escalated_to_id
    );
END;
$$;

COMMENT ON FUNCTION transaction.workflow_escalate IS 'Escalates a workflow to another BO user. Status remains IN_REVIEW, only assigned_to changes.';

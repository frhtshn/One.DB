-- ================================================================
-- WORKFLOW_ASSIGN: Workflow'u BO kullanıcısına ata
-- ================================================================
-- PENDING veya IN_REVIEW durumundaki workflow'u bir BO
-- kullanıcısına atar. Status IN_REVIEW'a geçer.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS transaction.workflow_assign(BIGINT, BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION transaction.workflow_assign(
    p_workflow_id       BIGINT,
    p_assigned_to_id    BIGINT,
    p_assigned_by_id    BIGINT
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

    -- Durum kontrolü: PENDING veya IN_REVIEW olmalı
    IF v_workflow.status NOT IN ('PENDING', 'IN_REVIEW') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.workflow.not-pending';
    END IF;

    -- Workflow güncelle
    UPDATE transaction.transaction_workflows SET
        assigned_to_id = p_assigned_to_id,
        status = 'IN_REVIEW',
        updated_at = NOW()
    WHERE id = p_workflow_id;

    -- Action kaydı
    INSERT INTO transaction.transaction_workflow_actions (
        workflow_id, action, performed_by_id, performed_by_type,
        note, created_at
    ) VALUES (
        p_workflow_id, 'ASSIGN', p_assigned_by_id, 'BO_USER',
        'Assigned to user ID: ' || p_assigned_to_id, NOW()
    );

    RETURN jsonb_build_object(
        'workflowId', p_workflow_id,
        'status', 'IN_REVIEW',
        'assignedToId', p_assigned_to_id
    );
END;
$$;

COMMENT ON FUNCTION transaction.workflow_assign IS 'Assigns a workflow to a BO user for review. Transitions PENDING or IN_REVIEW to IN_REVIEW with new assignee.';

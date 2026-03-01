-- ================================================================
-- WORKFLOW_GET: Workflow detayı + action geçmişi
-- ================================================================
-- Workflow bilgisi, bağlı transaction ve tüm action
-- geçmişini JSON olarak döner.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS transaction.workflow_get(BIGINT);

CREATE OR REPLACE FUNCTION transaction.workflow_get(
    p_workflow_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_workflow   JSONB;
    v_actions    JSONB;
    v_transaction JSONB;
    v_wf_record  RECORD;
BEGIN
    -- Workflow bul
    SELECT id, transaction_id, workflow_type, status, reason,
           created_by_id, assigned_to_id, created_at, updated_at
    INTO v_wf_record
    FROM transaction.transaction_workflows
    WHERE id = p_workflow_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.workflow.not-found';
    END IF;

    -- Action geçmişi
    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'actionId', a.id,
            'action', a.action,
            'performedById', a.performed_by_id,
            'performedByType', a.performed_by_type,
            'note', a.note,
            'createdAt', a.created_at
        ) ORDER BY a.created_at
    ), '[]'::JSONB)
    INTO v_actions
    FROM transaction.transaction_workflow_actions a
    WHERE a.workflow_id = p_workflow_id;

    -- Bağlı transaction bilgisi (varsa)
    IF v_wf_record.transaction_id IS NOT NULL THEN
        SELECT jsonb_build_object(
            'transactionId', t.id,
            'playerId', t.player_id,
            'transactionTypeId', t.transaction_type_id,
            'operationTypeId', t.operation_type_id,
            'amount', t.amount,
            'balanceAfter', t.balance_after,
            'source', t.source,
            'createdAt', t.created_at
        )
        INTO v_transaction
        FROM transaction.transactions t
        WHERE t.id = v_wf_record.transaction_id
        LIMIT 1;
    END IF;

    RETURN jsonb_build_object(
        'workflowId', v_wf_record.id,
        'transactionId', v_wf_record.transaction_id,
        'workflowType', v_wf_record.workflow_type,
        'status', v_wf_record.status,
        'reason', v_wf_record.reason,
        'createdById', v_wf_record.created_by_id,
        'assignedToId', v_wf_record.assigned_to_id,
        'createdAt', v_wf_record.created_at,
        'updatedAt', v_wf_record.updated_at,
        'transaction', COALESCE(v_transaction, 'null'::JSONB),
        'actions', v_actions
    );
END;
$$;

COMMENT ON FUNCTION transaction.workflow_get IS 'Returns workflow details with full action history and linked transaction information.';

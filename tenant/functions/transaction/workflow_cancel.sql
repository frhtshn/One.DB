-- ================================================================
-- WORKFLOW_CANCEL: Workflow'u iptal et
-- ================================================================
-- Sadece PENDING durumundaki workflow iptal edilebilir.
-- Oyuncu iptali veya sistem iptali için kullanılır.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS transaction.workflow_cancel(BIGINT, BIGINT, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION transaction.workflow_cancel(
    p_workflow_id           BIGINT,
    p_cancelled_by_id       BIGINT          DEFAULT NULL,
    p_cancelled_by_type     VARCHAR(30)     DEFAULT 'PLAYER',
    p_reason                VARCHAR(255)    DEFAULT NULL
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

    -- Durum kontrolü: sadece PENDING iptal edilebilir
    IF v_workflow.status != 'PENDING' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.workflow.not-pending';
    END IF;

    -- Workflow güncelle
    UPDATE transaction.transaction_workflows SET
        status = 'CANCELLED',
        reason = p_reason,
        updated_at = NOW()
    WHERE id = p_workflow_id;

    -- Action kaydı
    INSERT INTO transaction.transaction_workflow_actions (
        workflow_id, action, performed_by_id, performed_by_type,
        note, created_at
    ) VALUES (
        p_workflow_id, 'CANCEL', p_cancelled_by_id, p_cancelled_by_type,
        p_reason, NOW()
    );

    RETURN jsonb_build_object(
        'workflowId', p_workflow_id,
        'transactionId', v_workflow.transaction_id,
        'status', 'CANCELLED'
    );
END;
$$;

COMMENT ON FUNCTION transaction.workflow_cancel IS 'Cancels a workflow in PENDING status. Used for player cancellation or system timeout. IN_REVIEW workflows cannot be cancelled.';

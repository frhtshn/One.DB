-- ================================================================
-- WORKFLOW_CREATE: Onay akışı başlat
-- ================================================================
-- İşlem onay sürecini başlatır. Withdrawal, adjustment, yüksek
-- tutarlı veya şüpheli işlemler için workflow oluşturur.
-- Aynı transaction_id için aktif workflow varsa engeller.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS transaction.workflow_create(BIGINT, VARCHAR, VARCHAR, BIGINT);

CREATE OR REPLACE FUNCTION transaction.workflow_create(
    p_transaction_id    BIGINT          DEFAULT NULL,
    p_workflow_type     VARCHAR(30)     DEFAULT NULL,
    p_reason            VARCHAR(255)    DEFAULT NULL,
    p_created_by_id     BIGINT          DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_workflow_id       BIGINT;
    v_performed_by_type VARCHAR(30);
BEGIN
    -- Zorunlu alan kontrolü
    IF p_workflow_type IS NULL OR TRIM(p_workflow_type) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.workflow.invalid-type';
    END IF;

    -- Geçerli workflow tipi kontrolü
    IF p_workflow_type NOT IN ('WITHDRAWAL', 'HIGH_VALUE', 'SUSPICIOUS', 'ADJUSTMENT', 'KYC_REQUIRED') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.workflow.invalid-type';
    END IF;

    -- Aynı transaction_id için aktif workflow kontrolü
    IF p_transaction_id IS NOT NULL THEN
        IF EXISTS (
            SELECT 1 FROM transaction.transaction_workflows
            WHERE transaction_id = p_transaction_id
              AND status IN ('PENDING', 'IN_REVIEW')
        ) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.workflow.already-pending';
        END IF;
    END IF;

    -- Performed by type belirle
    v_performed_by_type := CASE WHEN p_created_by_id IS NOT NULL THEN 'BO_USER' ELSE 'SYSTEM' END;

    -- Workflow oluştur
    INSERT INTO transaction.transaction_workflows (
        transaction_id, workflow_type, status, reason,
        created_by_id, created_at, updated_at
    ) VALUES (
        p_transaction_id, p_workflow_type, 'PENDING', p_reason,
        p_created_by_id, NOW(), NOW()
    )
    RETURNING id INTO v_workflow_id;

    -- Action kaydı oluştur
    INSERT INTO transaction.transaction_workflow_actions (
        workflow_id, action, performed_by_id, performed_by_type,
        note, created_at
    ) VALUES (
        v_workflow_id, 'CREATE', p_created_by_id, v_performed_by_type,
        p_reason, NOW()
    );

    RETURN jsonb_build_object(
        'workflowId', v_workflow_id,
        'transactionId', p_transaction_id,
        'status', 'PENDING',
        'workflowType', p_workflow_type
    );
END;
$$;

COMMENT ON FUNCTION transaction.workflow_create IS 'Creates a new approval workflow for a transaction. Supports WITHDRAWAL, HIGH_VALUE, SUSPICIOUS, ADJUSTMENT, KYC_REQUIRED types. Prevents duplicate active workflows per transaction.';

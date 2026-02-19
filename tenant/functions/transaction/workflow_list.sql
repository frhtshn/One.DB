-- ================================================================
-- WORKFLOW_LIST: Workflow listesi (filtrelemeli + sayfalı)
-- ================================================================
-- Status, tip ve atanan kişiye göre filtreleme destekler.
-- Sayfalama ile sonuç döner.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS transaction.workflow_list(VARCHAR, VARCHAR, BIGINT, INT, INT);

CREATE OR REPLACE FUNCTION transaction.workflow_list(
    p_status            VARCHAR(30)     DEFAULT NULL,
    p_workflow_type     VARCHAR(30)     DEFAULT NULL,
    p_assigned_to_id    BIGINT          DEFAULT NULL,
    p_page              INT             DEFAULT 1,
    p_page_size         INT             DEFAULT 20
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_offset    INT;
    v_total     BIGINT;
    v_items     JSONB;
BEGIN
    -- Sayfalama hesapla
    v_offset := (GREATEST(p_page, 1) - 1) * p_page_size;

    -- Toplam sayı
    SELECT COUNT(*) INTO v_total
    FROM transaction.transaction_workflows w
    WHERE (p_status IS NULL OR w.status = p_status)
      AND (p_workflow_type IS NULL OR w.workflow_type = p_workflow_type)
      AND (p_assigned_to_id IS NULL OR w.assigned_to_id = p_assigned_to_id);

    -- Sonuçları al
    SELECT COALESCE(jsonb_agg(row_to_json), '[]'::JSONB)
    INTO v_items
    FROM (
        SELECT jsonb_build_object(
            'workflowId', w.id,
            'transactionId', w.transaction_id,
            'workflowType', w.workflow_type,
            'status', w.status,
            'reason', w.reason,
            'createdById', w.created_by_id,
            'assignedToId', w.assigned_to_id,
            'createdAt', w.created_at,
            'updatedAt', w.updated_at
        ) AS row_to_json
        FROM transaction.transaction_workflows w
        WHERE (p_status IS NULL OR w.status = p_status)
          AND (p_workflow_type IS NULL OR w.workflow_type = p_workflow_type)
          AND (p_assigned_to_id IS NULL OR w.assigned_to_id = p_assigned_to_id)
        ORDER BY w.created_at DESC
        LIMIT p_page_size
        OFFSET v_offset
    ) sub;

    RETURN jsonb_build_object(
        'items', v_items,
        'total', v_total,
        'page', GREATEST(p_page, 1),
        'pageSize', p_page_size
    );
END;
$$;

COMMENT ON FUNCTION transaction.workflow_list IS 'Lists workflows with optional filtering by status, type, and assignee. Paginated results.';

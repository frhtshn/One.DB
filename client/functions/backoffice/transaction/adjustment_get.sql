-- ================================================================
-- ADJUSTMENT_GET: Hesap düzeltme detayı
-- ================================================================
-- Düzeltme bilgisi ve bağlı workflow durumunu döner.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS transaction.adjustment_get(BIGINT);

CREATE OR REPLACE FUNCTION transaction.adjustment_get(
    p_adjustment_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'adjustmentId', a.id,
        'transactionId', a.transaction_id,
        'playerId', a.player_id,
        'walletType', a.wallet_type,
        'direction', a.direction,
        'amount', a.amount,
        'currencyCode', a.currency_code,
        'adjustmentType', a.adjustment_type,
        'status', a.status,
        'providerId', a.provider_id,
        'gameId', a.game_id,
        'externalRef', a.external_ref,
        'reason', a.reason,
        'createdById', a.created_by_id,
        'approvedById', a.approved_by_id,
        'workflowId', a.workflow_id,
        'createdAt', a.created_at,
        'appliedAt', a.applied_at,
        'workflow', CASE
            WHEN w.id IS NOT NULL THEN jsonb_build_object(
                'workflowId', w.id,
                'status', w.status,
                'assignedToId', w.assigned_to_id,
                'createdAt', w.created_at,
                'updatedAt', w.updated_at
            )
            ELSE NULL
        END
    )
    INTO v_result
    FROM transaction.transaction_adjustments a
    LEFT JOIN transaction.transaction_workflows w ON w.id = a.workflow_id
    WHERE a.id = p_adjustment_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.adjustment.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION transaction.adjustment_get IS 'Returns adjustment details with linked workflow status.';

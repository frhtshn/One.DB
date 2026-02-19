-- ================================================================
-- ADJUSTMENT_LIST: Hesap düzeltme listesi (filtrelemeli + sayfalı)
-- ================================================================
-- Oyuncu, durum ve tip bazında filtreleme destekler.
-- Sayfalama ile sonuç döner.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS transaction.adjustment_list(BIGINT, VARCHAR, VARCHAR, INT, INT);

CREATE OR REPLACE FUNCTION transaction.adjustment_list(
    p_player_id         BIGINT          DEFAULT NULL,
    p_status            VARCHAR(20)     DEFAULT NULL,
    p_adjustment_type   VARCHAR(30)     DEFAULT NULL,
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
    FROM transaction.transaction_adjustments a
    WHERE (p_player_id IS NULL OR a.player_id = p_player_id)
      AND (p_status IS NULL OR a.status = p_status)
      AND (p_adjustment_type IS NULL OR a.adjustment_type = p_adjustment_type);

    -- Sonuçları al
    SELECT COALESCE(jsonb_agg(row_to_json), '[]'::JSONB)
    INTO v_items
    FROM (
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
            'reason', a.reason,
            'createdById', a.created_by_id,
            'approvedById', a.approved_by_id,
            'workflowId', a.workflow_id,
            'createdAt', a.created_at,
            'appliedAt', a.applied_at
        ) AS row_to_json
        FROM transaction.transaction_adjustments a
        WHERE (p_player_id IS NULL OR a.player_id = p_player_id)
          AND (p_status IS NULL OR a.status = p_status)
          AND (p_adjustment_type IS NULL OR a.adjustment_type = p_adjustment_type)
        ORDER BY a.created_at DESC
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

COMMENT ON FUNCTION transaction.adjustment_list IS 'Lists account adjustments with optional filtering by player, status, and type. Paginated results.';

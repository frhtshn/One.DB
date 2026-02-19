-- ================================================================
-- ADJUSTMENT_CANCEL: Hesap düzeltme talebini iptal et
-- ================================================================
-- Workflow reddi sonrası çağrılır. Wallet DEĞİŞMEZ —
-- PENDING durumundaki düzeltme CANCELLED'a geçer.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS transaction.adjustment_cancel(BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION transaction.adjustment_cancel(
    p_adjustment_id     BIGINT,
    p_cancelled_by_id   BIGINT,
    p_reason            VARCHAR(255)    DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_status VARCHAR(20);
BEGIN
    -- Adjustment durum kontrolü
    SELECT status INTO v_status
    FROM transaction.transaction_adjustments
    WHERE id = p_adjustment_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.adjustment.not-found';
    END IF;

    IF v_status != 'PENDING' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.adjustment.not-pending';
    END IF;

    -- Adjustment iptal et
    UPDATE transaction.transaction_adjustments SET
        status = 'CANCELLED',
        approved_by_id = p_cancelled_by_id
    WHERE id = p_adjustment_id;

    RETURN TRUE;
END;
$$;

COMMENT ON FUNCTION transaction.adjustment_cancel IS 'Cancels a pending adjustment after workflow rejection. Wallet is not affected. Only PENDING adjustments can be cancelled.';

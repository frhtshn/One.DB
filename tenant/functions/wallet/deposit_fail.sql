-- ================================================================
-- DEPOSIT_FAIL: Para yatırma başarısız işaretle
-- ================================================================
-- PSP callback'i başarısız döndüğünde çağrılır.
-- Wallet bakiyesi DEĞİŞMEZ (zaten eklenmemişti).
-- Zaten onaylanmış deposit fail edilemez.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS wallet.deposit_fail(VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION wallet.deposit_fail(
    p_idempotency_key VARCHAR(100),
    p_reason          VARCHAR(255) DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_tx_id        BIGINT;
    v_confirmed_at TIMESTAMPTZ;
    v_created_at   TIMESTAMPTZ;
BEGIN
    -- İdempotency key ile transaction bul
    SELECT t.id, t.confirmed_at, t.created_at
    INTO v_tx_id, v_confirmed_at, v_created_at
    FROM transaction.transactions t
    WHERE t.idempotency_key = p_idempotency_key
      AND t.source = 'PAYMENT'
      AND t.operation_type_id = 2  -- credit
    LIMIT 1;

    IF v_tx_id IS NULL THEN
        -- Transaction bulunamazsa sessizce true dön (idempotent davranış)
        RETURN true;
    END IF;

    -- Zaten onaylanmış → fail edilemez
    IF v_confirmed_at IS NOT NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.deposit-fail.already-confirmed';
    END IF;

    -- Transaction'ı fail olarak işaretle
    UPDATE transaction.transactions
    SET description = p_reason,
        processed_at = NOW()
    WHERE id = v_tx_id
      AND created_at = v_created_at;

    RETURN true;
END;
$$;

COMMENT ON FUNCTION wallet.deposit_fail IS 'Marks a pending deposit as failed. Wallet balance is unchanged (was never credited). Cannot fail an already confirmed deposit.';

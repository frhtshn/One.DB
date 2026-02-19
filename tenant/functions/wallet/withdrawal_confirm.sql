-- ================================================================
-- WITHDRAWAL_CONFIRM: Para çekme onayla
-- ================================================================
-- PSP payout başarılı veya BO onayı sonrası çağrılır.
-- Wallet bakiyesi DEĞİŞMEZ (initiate'de düşürülmüştü).
-- Sadece confirmed_at güncellenir. İdempotent: zaten onaylanmış
-- tx için true döner (exception yok).
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS wallet.withdrawal_confirm(VARCHAR);

CREATE OR REPLACE FUNCTION wallet.withdrawal_confirm(
    p_idempotency_key VARCHAR(100)
)
RETURNS BOOLEAN
LANGUAGE plpgsql
AS $$
DECLARE
    v_tx_id        BIGINT;
    v_confirmed_at TIMESTAMPTZ;
    v_created_at   TIMESTAMPTZ;
BEGIN
    -- İdempotency key ile pending withdrawal tx bul
    SELECT t.id, t.confirmed_at, t.created_at
    INTO v_tx_id, v_confirmed_at, v_created_at
    FROM transaction.transactions t
    WHERE t.idempotency_key = p_idempotency_key
      AND t.source = 'PAYMENT'
      AND t.operation_type_id = 1  -- debit
    LIMIT 1;

    IF v_tx_id IS NULL THEN
        -- Bulunamazsa idempotent true dön
        RETURN true;
    END IF;

    -- Zaten onaylanmış → idempotent dönüş
    IF v_confirmed_at IS NOT NULL THEN
        RETURN true;
    END IF;

    -- Transaction'ı onayla (bakiye DEĞİŞMEZ — initiate'de düşürülmüştü)
    UPDATE transaction.transactions
    SET confirmed_at = NOW(),
        processed_at = NOW()
    WHERE id = v_tx_id
      AND created_at = v_created_at;

    RETURN true;
END;
$$;

COMMENT ON FUNCTION wallet.withdrawal_confirm IS 'Confirms a pending withdrawal. Wallet balance is unchanged (already debited at initiate). Idempotent: returns true for already-confirmed transactions.';

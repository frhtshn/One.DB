-- ================================================================
-- BONUS_AWARD_CANCEL: Bonus iptal et
-- ================================================================
-- Admin veya sistem tarafından bonus iptal edilir.
-- Kalan bakiye BONUS wallet'tan düşülür.
-- İptal sebebi ve iptal eden kaydedilir.
-- Sadece aktif/pending bonuslar iptal edilebilir.
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_award_cancel(BIGINT, VARCHAR, BIGINT);

CREATE OR REPLACE FUNCTION bonus.bonus_award_cancel(
    p_id BIGINT,
    p_cancellation_reason VARCHAR(255) DEFAULT NULL,
    p_cancelled_by BIGINT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_award RECORD;
    v_wallet_id BIGINT;
    v_tx_id BIGINT;
BEGIN
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-award.id-required';
    END IF;

    -- Award bilgisi al
    SELECT id, player_id, current_balance, currency, status
    INTO v_award
    FROM bonus.bonus_awards
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.bonus-award.not-found';
    END IF;

    IF v_award.status NOT IN ('pending', 'active', 'wagering_complete') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-award.cannot-cancel';
    END IF;

    -- Kalan bakiyeyi BONUS wallet'tan düş
    IF v_award.current_balance > 0 THEN
        SELECT id INTO v_wallet_id
        FROM wallet.wallets
        WHERE player_id = v_award.player_id
          AND wallet_type = 'BONUS'
          AND currency_code = v_award.currency
          AND status = 1;

        IF v_wallet_id IS NOT NULL THEN
            -- Debit transaction
            INSERT INTO transaction.transactions (
                player_id, wallet_id,
                transaction_type_id, operation_type_id,
                amount, balance_after,
                bonus_award_id,
                source, description,
                created_at
            ) VALUES (
                v_award.player_id, v_wallet_id,
                41, 2,
                v_award.current_balance,
                (SELECT balance FROM wallet.wallet_snapshots WHERE wallet_id = v_wallet_id) - v_award.current_balance,
                p_id,
                'BONUS', 'Bonus cancelled: ' || COALESCE(p_cancellation_reason, 'no reason'),
                NOW()
            )
            RETURNING id INTO v_tx_id;

            -- Wallet snapshot güncelle
            UPDATE wallet.wallet_snapshots SET
                balance = balance - v_award.current_balance,
                last_transaction_id = v_tx_id,
                updated_at = NOW()
            WHERE wallet_id = v_wallet_id;
        END IF;
    END IF;

    -- Award güncelle
    UPDATE bonus.bonus_awards SET
        status = 'cancelled',
        current_balance = 0,
        cancellation_reason = p_cancellation_reason,
        cancelled_by = p_cancelled_by,
        cancelled_at = NOW(),
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION bonus.bonus_award_cancel(BIGINT, VARCHAR, BIGINT) IS 'Cancels an active bonus award. Deducts remaining balance from BONUS wallet. Records cancellation reason and admin who cancelled.';

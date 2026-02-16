-- ================================================================
-- BONUS_AWARD_EXPIRE: Süresi dolmuş bonusları expire et
-- ================================================================
-- Worker scheduler tarafından periyodik çağrılır.
-- expires_at < NOW() olan aktif award'ları expire eder.
-- Kalan bakiye BONUS wallet'tan düşülür.
-- İşlenen award sayısını döner.
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_award_expire(INTEGER);

CREATE OR REPLACE FUNCTION bonus.bonus_award_expire(
    p_batch_size INTEGER DEFAULT 100
)
RETURNS INTEGER
LANGUAGE plpgsql
AS $$
DECLARE
    v_award RECORD;
    v_wallet_id BIGINT;
    v_tx_id BIGINT;
    v_count INTEGER := 0;
BEGIN
    FOR v_award IN
        SELECT id, player_id, current_balance, currency
        FROM bonus.bonus_awards
        WHERE status IN ('pending', 'active')
          AND expires_at IS NOT NULL
          AND expires_at < NOW()
        ORDER BY expires_at ASC
        LIMIT p_batch_size
        FOR UPDATE SKIP LOCKED
    LOOP
        -- Kalan bakiyeyi BONUS wallet'tan düş
        IF v_award.current_balance > 0 THEN
            SELECT w.id INTO v_wallet_id
            FROM wallet.wallets w
            WHERE w.player_id = v_award.player_id
              AND w.wallet_type = 'BONUS'
              AND w.currency_code = v_award.currency
              AND w.status = 1;

            IF v_wallet_id IS NOT NULL THEN
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
                    v_award.id,
                    'BONUS', 'Bonus expired',
                    NOW()
                )
                RETURNING id INTO v_tx_id;

                UPDATE wallet.wallet_snapshots SET
                    balance = balance - v_award.current_balance,
                    last_transaction_id = v_tx_id,
                    updated_at = NOW()
                WHERE wallet_id = v_wallet_id;
            END IF;
        END IF;

        -- Award durumu güncelle
        UPDATE bonus.bonus_awards SET
            status = 'expired',
            current_balance = 0,
            cancelled_at = NOW(),
            cancellation_reason = 'Bonus expired',
            updated_at = NOW()
        WHERE id = v_award.id;

        v_count := v_count + 1;
    END LOOP;

    RETURN v_count;
END;
$$;

COMMENT ON FUNCTION bonus.bonus_award_expire(INTEGER) IS 'Batch expires bonus awards past their expiry date. Deducts remaining balance from BONUS wallet. Uses SKIP LOCKED for concurrent worker safety. Returns count of expired awards.';

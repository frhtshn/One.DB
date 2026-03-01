-- ================================================================
-- BONUS_AWARD_COMPLETE: Çevrimi tamamlanan bonusu REAL'e aktar
-- ================================================================
-- wagering_completed = true olan bonus'un bakiyesini
-- BONUS wallet → REAL wallet'a transfer eder.
-- max_withdrawal_amount limiti uygulanır.
-- Fazla bakiye forfeit edilir.
-- completion_transaction_id kaydedilir.
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_award_complete(BIGINT);

CREATE OR REPLACE FUNCTION bonus.bonus_award_complete(
    p_id BIGINT
)
RETURNS DECIMAL
LANGUAGE plpgsql
AS $$
DECLARE
    v_award RECORD;
    v_transfer_amount DECIMAL(18,2);
    v_forfeit_amount DECIMAL(18,2);
    v_bonus_wallet_id BIGINT;
    v_real_wallet_id BIGINT;
    v_bonus_balance DECIMAL;
    v_real_balance DECIMAL;
    v_debit_tx_id BIGINT;
    v_credit_tx_id BIGINT;
BEGIN
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-award.id-required';
    END IF;

    -- Award bilgisi al
    SELECT id, player_id, current_balance, currency, status,
           wagering_completed, max_withdrawal_amount, usage_criteria
    INTO v_award
    FROM bonus.bonus_awards
    WHERE id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.bonus-award.not-found';
    END IF;

    -- Durum kontrolü
    IF v_award.status NOT IN ('active', 'wagering_complete') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-award.not-completable';
    END IF;

    -- Çevrim kontrolü (çevrimsiz bonuslar withdrawal_policy'ye göre davranılır)
    IF v_award.wagering_completed = false AND
       COALESCE((v_award.usage_criteria->>'wagering_multiplier')::DECIMAL, 0) > 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-award.wagering-not-complete';
    END IF;

    -- Transfer tutarı hesapla (max_withdrawal_amount limiti)
    v_transfer_amount := v_award.current_balance;
    IF v_award.max_withdrawal_amount IS NOT NULL AND v_transfer_amount > v_award.max_withdrawal_amount THEN
        v_transfer_amount := v_award.max_withdrawal_amount;
    END IF;
    v_forfeit_amount := v_award.current_balance - v_transfer_amount;

    -- Bakiye yoksa sadece durumu güncelle
    IF v_award.current_balance <= 0 THEN
        UPDATE bonus.bonus_awards SET
            status = 'completed',
            current_balance = 0,
            completed_at = NOW(),
            updated_at = NOW()
        WHERE id = p_id;
        RETURN 0;
    END IF;

    -- BONUS ve REAL wallet'ları bul
    SELECT id INTO v_bonus_wallet_id
    FROM wallet.wallets
    WHERE player_id = v_award.player_id
      AND wallet_type = 'BONUS'
      AND currency_code = v_award.currency
      AND status = 1;

    SELECT id INTO v_real_wallet_id
    FROM wallet.wallets
    WHERE player_id = v_award.player_id
      AND wallet_type = 'REAL'
      AND currency_code = v_award.currency
      AND status = 1;

    IF v_bonus_wallet_id IS NULL OR v_real_wallet_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-award.wallet-not-found';
    END IF;

    -- BONUS wallet'tan düş (tüm bakiye — transfer + forfeit)
    SELECT ws.balance INTO v_bonus_balance
    FROM wallet.wallet_snapshots ws WHERE ws.wallet_id = v_bonus_wallet_id FOR UPDATE;

    INSERT INTO transaction.transactions (
        player_id, wallet_id,
        transaction_type_id, operation_type_id,
        amount, balance_after,
        bonus_award_id,
        source, description,
        created_at
    ) VALUES (
        v_award.player_id, v_bonus_wallet_id,
        42, 2,
        v_award.current_balance, v_bonus_balance - v_award.current_balance,
        p_id,
        'BONUS', 'Bonus completion: transfer ' || v_transfer_amount || ', forfeit ' || v_forfeit_amount,
        NOW()
    )
    RETURNING id INTO v_debit_tx_id;

    UPDATE wallet.wallet_snapshots SET
        balance = balance - v_award.current_balance,
        last_transaction_id = v_debit_tx_id,
        updated_at = NOW()
    WHERE wallet_id = v_bonus_wallet_id;

    -- REAL wallet'a transfer tutarını ekle
    SELECT ws.balance INTO v_real_balance
    FROM wallet.wallet_snapshots ws WHERE ws.wallet_id = v_real_wallet_id FOR UPDATE;

    INSERT INTO transaction.transactions (
        player_id, wallet_id,
        transaction_type_id, operation_type_id,
        amount, balance_after,
        bonus_award_id,
        source, description,
        created_at
    ) VALUES (
        v_award.player_id, v_real_wallet_id,
        42, 1,
        v_transfer_amount, v_real_balance + v_transfer_amount,
        p_id,
        'BONUS', 'Bonus to real transfer: award_id=' || p_id,
        NOW()
    )
    RETURNING id INTO v_credit_tx_id;

    UPDATE wallet.wallet_snapshots SET
        balance = balance + v_transfer_amount,
        last_transaction_id = v_credit_tx_id,
        updated_at = NOW()
    WHERE wallet_id = v_real_wallet_id;

    -- Award durumu güncelle
    UPDATE bonus.bonus_awards SET
        status = 'completed',
        current_balance = 0,
        completion_transaction_id = v_credit_tx_id,
        completed_at = NOW(),
        updated_at = NOW()
    WHERE id = p_id;

    RETURN v_transfer_amount;
END;
$$;

COMMENT ON FUNCTION bonus.bonus_award_complete(BIGINT) IS 'Completes a bonus award by transferring earned balance from BONUS to REAL wallet. Applies max_withdrawal_amount cap. Returns transferred amount. Excess is forfeited.';

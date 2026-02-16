-- ================================================================
-- BONUS_AWARD_CREATE: Oyuncuya bonus ver
-- ================================================================
-- Bonus Worker tarafından çağrılır. Auth-agnostic.
-- bonus_awards INSERT + BONUS wallet credit + transaction kaydı.
-- usage_criteria ve rule_snapshot kopyalanır.
-- wagering_target hesaplanır: amount * multiplier.
-- max_withdrawal_amount hesaplanır: amount * factor.
-- ================================================================

DROP FUNCTION IF EXISTS bonus.bonus_award_create(BIGINT, BIGINT, VARCHAR, VARCHAR, BIGINT, BIGINT, DECIMAL, CHAR, TEXT, TEXT, TEXT, TIMESTAMPTZ, BIGINT);

CREATE OR REPLACE FUNCTION bonus.bonus_award_create(
    p_player_id BIGINT,
    p_bonus_rule_id BIGINT,
    p_bonus_type_code VARCHAR(50),
    p_bonus_subtype VARCHAR(30) DEFAULT NULL,
    p_promo_code_id BIGINT DEFAULT NULL,
    p_campaign_id BIGINT DEFAULT NULL,
    p_bonus_amount DECIMAL(18,2) DEFAULT NULL,
    p_currency CHAR(3) DEFAULT NULL,
    p_usage_criteria TEXT DEFAULT NULL,
    p_rule_snapshot TEXT DEFAULT NULL,
    p_reward_details TEXT DEFAULT NULL,
    p_expires_at TIMESTAMPTZ DEFAULT NULL,
    p_awarded_by BIGINT DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_new_id BIGINT;
    v_usage JSONB;
    v_wagering_multiplier DECIMAL;
    v_wagering_target DECIMAL;
    v_max_withdrawal_factor DECIMAL;
    v_max_withdrawal_amount DECIMAL;
    v_wallet_id BIGINT;
    v_wallet_balance DECIMAL;
    v_tx_id BIGINT;
BEGIN
    -- Zorunlu alan kontrolleri
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-award.player-required';
    END IF;

    IF p_bonus_rule_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-award.rule-required';
    END IF;

    IF p_bonus_amount IS NULL OR p_bonus_amount <= 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-award.amount-required';
    END IF;

    IF p_currency IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.bonus-award.currency-required';
    END IF;

    -- usage_criteria'dan çevrim ve max çekim hesapla
    v_usage := CASE WHEN p_usage_criteria IS NOT NULL THEN p_usage_criteria::JSONB ELSE '{}'::JSONB END;

    v_wagering_multiplier := COALESCE((v_usage->>'wagering_multiplier')::DECIMAL, 0);
    v_wagering_target := CASE
        WHEN v_wagering_multiplier > 0 THEN p_bonus_amount * v_wagering_multiplier
        ELSE NULL
    END;

    v_max_withdrawal_factor := (v_usage->>'max_withdrawal_factor')::DECIMAL;
    v_max_withdrawal_amount := CASE
        WHEN v_max_withdrawal_factor IS NOT NULL AND v_max_withdrawal_factor > 0
        THEN p_bonus_amount * v_max_withdrawal_factor
        ELSE NULL
    END;

    -- BONUS wallet bul veya oluştur
    SELECT id INTO v_wallet_id
    FROM wallet.wallets
    WHERE player_id = p_player_id
      AND wallet_type = 'BONUS'
      AND currency_code = p_currency
      AND status = 1;

    IF v_wallet_id IS NULL THEN
        INSERT INTO wallet.wallets (
            player_id, wallet_type, currency_type, currency_code,
            status, is_default, created_at, updated_at
        ) VALUES (
            p_player_id, 'BONUS', 1, p_currency,
            1, false, NOW(), NOW()
        )
        RETURNING id INTO v_wallet_id;

        -- Snapshot oluştur
        INSERT INTO wallet.wallet_snapshots (wallet_id, balance, last_transaction_id, updated_at)
        VALUES (v_wallet_id, 0, 0, NOW());
    END IF;

    -- Bonus award INSERT
    INSERT INTO bonus.bonus_awards (
        player_id, bonus_rule_id, bonus_type_code, bonus_subtype,
        promo_code_id, campaign_id,
        bonus_amount, currency,
        rule_snapshot, usage_criteria, reward_details,
        wagering_target, wagering_progress, wagering_completed,
        max_withdrawal_amount, current_balance,
        expires_at, status,
        awarded_by, awarded_at, created_at, updated_at
    ) VALUES (
        p_player_id, p_bonus_rule_id, p_bonus_type_code, p_bonus_subtype,
        p_promo_code_id, p_campaign_id,
        p_bonus_amount, p_currency,
        CASE WHEN p_rule_snapshot IS NOT NULL THEN p_rule_snapshot::JSONB ELSE NULL END,
        v_usage,
        CASE WHEN p_reward_details IS NOT NULL THEN p_reward_details::JSONB ELSE NULL END,
        v_wagering_target, 0, false,
        v_max_withdrawal_amount, p_bonus_amount,
        p_expires_at, 'active',
        p_awarded_by, NOW(), NOW(), NOW()
    )
    RETURNING id INTO v_new_id;

    -- BONUS wallet'a credit (wallet_snapshots güncelle)
    SELECT ws.balance INTO v_wallet_balance
    FROM wallet.wallet_snapshots ws
    WHERE ws.wallet_id = v_wallet_id
    FOR UPDATE;

    -- Transaction kaydı oluştur
    INSERT INTO transaction.transactions (
        player_id, wallet_id,
        transaction_type_id, operation_type_id,
        amount, balance_after,
        bonus_award_id,
        source, description,
        created_at
    ) VALUES (
        p_player_id, v_wallet_id,
        40, 1,
        p_bonus_amount, v_wallet_balance + p_bonus_amount,
        v_new_id,
        'BONUS', 'Bonus award credit: rule_id=' || p_bonus_rule_id,
        NOW()
    )
    RETURNING id INTO v_tx_id;

    -- Wallet snapshot güncelle
    UPDATE wallet.wallet_snapshots SET
        balance = balance + p_bonus_amount,
        last_transaction_id = v_tx_id,
        updated_at = NOW()
    WHERE wallet_id = v_wallet_id;

    -- Award'a transaction referansı yaz
    UPDATE bonus.bonus_awards SET
        tenant_transaction_id = v_tx_id
    WHERE id = v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION bonus.bonus_award_create IS 'Awards a bonus to a player. Creates award record, credits BONUS wallet, records transaction. Calculates wagering_target and max_withdrawal_amount from usage_criteria. Called by Bonus Worker.';

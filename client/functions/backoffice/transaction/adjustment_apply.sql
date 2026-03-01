-- ================================================================
-- ADJUSTMENT_APPLY: Hesap düzeltmesini wallet'a uygula
-- ================================================================
-- Workflow onayı sonrası çağrılır. Wallet bakiyesini değiştirir
-- ve transaction kaydı oluşturur.
-- CREDIT → tx_type=95 (adjustment.credit), op_type=2
-- DEBIT  → tx_type=96 (adjustment.debit),  op_type=1
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS transaction.adjustment_apply(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION transaction.adjustment_apply(
    p_adjustment_id     BIGINT,
    p_approved_by_id    BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_adj           RECORD;
    v_wallet_id     BIGINT;
    v_balance       NUMERIC(18,8);
    v_new_balance   NUMERIC(18,8);
    v_bonus_balance NUMERIC(18,8) := 0;
    v_tx_id         BIGINT;
    v_tx_type_id    SMALLINT;
    v_op_type_id    SMALLINT;
    v_metadata_json JSONB;
BEGIN
    -- Adjustment bul
    SELECT id, player_id, wallet_type, direction, amount, currency_code,
           adjustment_type, status, provider_id, game_id, external_ref, reason
    INTO v_adj
    FROM transaction.transaction_adjustments
    WHERE id = p_adjustment_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.adjustment.not-found';
    END IF;

    -- Durum kontrolü
    IF v_adj.status != 'PENDING' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.adjustment.not-pending';
    END IF;

    -- İşlem yönünü belirle
    IF v_adj.direction = 'CREDIT' THEN
        v_tx_type_id := 95;  -- adjustment.credit
        v_op_type_id := 2;   -- credit
    ELSE
        v_tx_type_id := 96;  -- adjustment.debit
        v_op_type_id := 1;   -- debit
    END IF;

    -- Wallet bul
    SELECT w.id INTO v_wallet_id
    FROM wallet.wallets w
    WHERE w.player_id = v_adj.player_id
      AND w.wallet_type = v_adj.wallet_type
      AND w.currency_code = v_adj.currency_code
      AND w.status = 1;

    IF v_wallet_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.wallet.wallet-not-found';
    END IF;

    -- Wallet snapshot kilitle
    SELECT ws.balance INTO v_balance
    FROM wallet.wallet_snapshots ws
    WHERE ws.wallet_id = v_wallet_id
    FOR UPDATE;

    -- DEBIT için bakiye kontrolü
    IF v_adj.direction = 'DEBIT' AND v_balance < v_adj.amount THEN
        RAISE EXCEPTION USING ERRCODE = 'P0402', MESSAGE = 'error.adjustment.insufficient-balance';
    END IF;

    -- Yeni bakiye hesapla
    IF v_adj.direction = 'CREDIT' THEN
        v_new_balance := v_balance + v_adj.amount;
    ELSE
        v_new_balance := v_balance - v_adj.amount;
    END IF;

    -- Metadata hazırla
    v_metadata_json := jsonb_build_object(
        'adjustmentId', v_adj.id,
        'adjustmentType', v_adj.adjustment_type,
        'reason', v_adj.reason,
        'walletType', v_adj.wallet_type
    );

    IF v_adj.provider_id IS NOT NULL THEN
        v_metadata_json := v_metadata_json || jsonb_build_object('providerId', v_adj.provider_id);
    END IF;

    IF v_adj.game_id IS NOT NULL THEN
        v_metadata_json := v_metadata_json || jsonb_build_object('gameId', v_adj.game_id);
    END IF;

    -- Transaction oluştur
    INSERT INTO transaction.transactions (
        player_id, wallet_id,
        transaction_type_id, operation_type_id,
        amount, balance_after,
        external_reference_id,
        source, description, metadata,
        requested_at, confirmed_at, created_at
    ) VALUES (
        v_adj.player_id, v_wallet_id,
        v_tx_type_id, v_op_type_id,
        v_adj.amount, v_new_balance,
        v_adj.external_ref,
        'ADMIN', v_adj.reason, v_metadata_json,
        v_adj.created_at, NOW(), NOW()
    )
    RETURNING id INTO v_tx_id;

    -- Adjustment güncelle
    UPDATE transaction.transaction_adjustments SET
        status = 'APPLIED',
        transaction_id = v_tx_id,
        approved_by_id = p_approved_by_id,
        applied_at = NOW()
    WHERE id = p_adjustment_id;

    -- Wallet snapshot güncelle
    UPDATE wallet.wallet_snapshots SET
        balance = v_new_balance,
        last_transaction_id = v_tx_id,
        updated_at = NOW()
    WHERE wallet_id = v_wallet_id;

    -- Bonus bakiye oku (REAL wallet ise BONUS'u da dön, tersi de geçerli)
    SELECT COALESCE(ws.balance, 0) INTO v_bonus_balance
    FROM wallet.wallets w
    JOIN wallet.wallet_snapshots ws ON ws.wallet_id = w.id
    WHERE w.player_id = v_adj.player_id
      AND w.wallet_type = 'BONUS'
      AND w.currency_code = v_adj.currency_code
      AND w.status = 1;

    RETURN jsonb_build_object(
        'adjustmentId', v_adj.id,
        'transactionId', v_tx_id,
        'cash', CASE WHEN v_adj.wallet_type = 'REAL' THEN v_new_balance ELSE v_balance END,
        'bonus', CASE WHEN v_adj.wallet_type = 'BONUS' THEN v_new_balance ELSE COALESCE(v_bonus_balance, 0) END,
        'currency', v_adj.currency_code
    );
END;
$$;

COMMENT ON FUNCTION transaction.adjustment_apply IS 'Applies a pending adjustment to the player wallet. Creates a transaction record, updates wallet balance. Called after workflow approval. Source=ADMIN, tx_type=95/96.';

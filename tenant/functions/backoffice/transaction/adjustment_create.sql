-- ================================================================
-- ADJUSTMENT_CREATE: Hesap düzeltme talebi oluştur
-- ================================================================
-- BO operatörünün başlattığı hesap düzeltme. Wallet DEĞİŞMEZ —
-- workflow onayı sonrası adjustment_apply ile uygulanır.
-- GAME_CORRECTION tipi GGR'a etki eder (provider_id zorunlu).
-- Auth-agnostic (backend çağırır, BO user ID parametre ile gelir).
-- ================================================================

DROP FUNCTION IF EXISTS transaction.adjustment_create(BIGINT, VARCHAR, VARCHAR, DECIMAL, VARCHAR, VARCHAR, VARCHAR, BIGINT, BIGINT, BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION transaction.adjustment_create(
    p_player_id         BIGINT,
    p_wallet_type       VARCHAR(10),
    p_direction         VARCHAR(10),
    p_amount            DECIMAL(18,8),
    p_currency_code     VARCHAR(20),
    p_adjustment_type   VARCHAR(30),
    p_reason            VARCHAR(500),
    p_created_by_id     BIGINT,
    p_provider_id       BIGINT          DEFAULT NULL,
    p_game_id           BIGINT          DEFAULT NULL,
    p_external_ref      VARCHAR(100)    DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_player_status     SMALLINT;
    v_adjustment_id     BIGINT;
BEGIN
    -- Zorunlu alan kontrolleri
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.deposit.player-required';
    END IF;

    IF p_amount IS NULL OR p_amount <= 0 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.deposit.invalid-amount';
    END IF;

    -- Direction kontrolü
    IF p_direction IS NULL OR p_direction NOT IN ('CREDIT', 'DEBIT') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.adjustment.invalid-direction';
    END IF;

    -- Wallet type kontrolü
    IF p_wallet_type IS NULL OR p_wallet_type NOT IN ('REAL', 'BONUS') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.adjustment.invalid-wallet-type';
    END IF;

    -- Adjustment type kontrolü
    IF p_adjustment_type IS NULL OR p_adjustment_type NOT IN ('GAME_CORRECTION', 'BONUS_CORRECTION', 'FRAUD', 'MANUAL') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.adjustment.invalid-type';
    END IF;

    -- GAME_CORRECTION ise provider_id zorunlu
    IF p_adjustment_type = 'GAME_CORRECTION' AND p_provider_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.adjustment.provider-required';
    END IF;

    -- Player durum kontrolü
    SELECT status INTO v_player_status
    FROM auth.players
    WHERE id = p_player_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.wallet.player-not-found';
    END IF;

    IF v_player_status != 1 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.deposit.player-not-active';
    END IF;

    -- Adjustment kaydı oluştur (wallet DEĞİŞMEZ)
    INSERT INTO transaction.transaction_adjustments (
        player_id, wallet_type, direction, amount, currency_code,
        adjustment_type, status, provider_id, game_id, external_ref,
        reason, created_by_id, created_at
    ) VALUES (
        p_player_id, p_wallet_type, p_direction, p_amount, p_currency_code,
        p_adjustment_type, 'PENDING', p_provider_id, p_game_id, p_external_ref,
        p_reason, p_created_by_id, NOW()
    )
    RETURNING id INTO v_adjustment_id;

    RETURN jsonb_build_object(
        'adjustmentId', v_adjustment_id,
        'playerId', p_player_id,
        'walletType', p_wallet_type,
        'direction', p_direction,
        'amount', p_amount,
        'status', 'PENDING'
    );
END;
$$;

COMMENT ON FUNCTION transaction.adjustment_create IS 'Creates a pending account adjustment request. Wallet is NOT modified until adjustment_apply is called after workflow approval. GAME_CORRECTION type requires provider_id for GGR reporting.';

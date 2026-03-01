-- ================================================================
-- PLAYER_BALANCE_GET: Oyuncu bakiye sorgula
-- ================================================================
-- REAL ve BONUS wallet bakiyelerini döner. PP authenticate/balance
-- ve Hub88 /user/balance endpoint'leri için kullanılır.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS wallet.player_balance_get(BIGINT, VARCHAR);

CREATE OR REPLACE FUNCTION wallet.player_balance_get(
    p_player_id BIGINT,
    p_currency_code VARCHAR(20)
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_player_status SMALLINT;
    v_cash NUMERIC(18,8) := 0;
    v_bonus NUMERIC(18,8) := 0;
BEGIN
    -- Player durum kontrolü
    SELECT status INTO v_player_status
    FROM auth.players
    WHERE id = p_player_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.wallet.player-not-found';
    END IF;

    IF v_player_status != 1 THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.wallet.player-frozen';
    END IF;

    -- REAL wallet bakiyesi
    SELECT COALESCE(ws.balance, 0) INTO v_cash
    FROM wallet.wallets w
    JOIN wallet.wallet_snapshots ws ON ws.wallet_id = w.id
    WHERE w.player_id = p_player_id
      AND w.wallet_type = 'REAL'
      AND w.currency_code = p_currency_code
      AND w.status = 1;

    -- BONUS wallet bakiyesi
    SELECT COALESCE(ws.balance, 0) INTO v_bonus
    FROM wallet.wallets w
    JOIN wallet.wallet_snapshots ws ON ws.wallet_id = w.id
    WHERE w.player_id = p_player_id
      AND w.wallet_type = 'BONUS'
      AND w.currency_code = p_currency_code
      AND w.status = 1;

    RETURN jsonb_build_object(
        'cash', v_cash,
        'bonus', v_bonus,
        'currency', p_currency_code
    );
END;
$$;

COMMENT ON FUNCTION wallet.player_balance_get IS 'Returns REAL and BONUS wallet balances for a player and currency. Used by provider balance endpoints.';

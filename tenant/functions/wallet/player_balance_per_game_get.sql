-- ================================================================
-- PLAYER_BALANCE_PER_GAME_GET: Oyun bazlı bakiye sorgula
-- ================================================================
-- PP getBalancePerGame endpoint'i için. Her oyun kodu için
-- aynı REAL+BONUS bakiyesini döner. Hub88 kullanmaz.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS wallet.player_balance_per_game_get(BIGINT, VARCHAR, TEXT);

CREATE OR REPLACE FUNCTION wallet.player_balance_per_game_get(
    p_player_id BIGINT,
    p_currency_code VARCHAR(20),
    p_game_codes TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_player_status SMALLINT;
    v_cash NUMERIC(18,8) := 0;
    v_bonus NUMERIC(18,8) := 0;
    v_game_code TEXT;
    v_result JSONB := '[]'::JSONB;
    v_codes TEXT[];
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

    -- Game code'lar yoksa tek balance dön
    IF p_game_codes IS NULL OR TRIM(p_game_codes) = '' THEN
        RETURN jsonb_build_object(
            'cash', v_cash,
            'bonus', v_bonus,
            'currency', p_currency_code
        );
    END IF;

    -- Virgülle ayrılmış game code'ları parse et
    v_codes := string_to_array(TRIM(p_game_codes), ',');

    -- Her game code için aynı bakiyeyi dön
    FOREACH v_game_code IN ARRAY v_codes LOOP
        v_result := v_result || jsonb_build_object(
            'gameCode', TRIM(v_game_code),
            'cash', v_cash,
            'bonus', v_bonus,
            'currency', p_currency_code
        );
    END LOOP;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION wallet.player_balance_per_game_get IS 'Returns player balance per game code for PP getBalancePerGame endpoint. Same balance is returned for all games.';

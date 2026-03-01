-- ================================================================
-- GAME_LIMITS_SYNC: Core->Tenant currency limits senkronizasyonu
-- ================================================================
-- p_limits TEXT → JSONB array cast.
-- Mevcut kayıtlar güncellenir, yeniler eklenir.
-- Artık desteklenmeyen limitler is_active=false yapılır.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS game.game_limits_sync(BIGINT, TEXT);

CREATE OR REPLACE FUNCTION game.game_limits_sync(
    p_game_id BIGINT,
    p_limits TEXT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_limits JSONB;
    v_elem JSONB;
    v_synced_currencies VARCHAR(20)[] := '{}';
BEGIN
    -- Parametre kontrolleri
    IF p_game_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.id-required';
    END IF;

    IF NOT EXISTS(SELECT 1 FROM game.game_settings WHERE game_id = p_game_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.game.not-found';
    END IF;

    IF p_limits IS NULL OR TRIM(p_limits) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.limits-data-required';
    END IF;

    v_limits := p_limits::JSONB;

    IF jsonb_typeof(v_limits) != 'array' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.limits-invalid-format';
    END IF;

    -- Her eleman için UPSERT
    FOR v_elem IN SELECT * FROM jsonb_array_elements(v_limits)
    LOOP
        INSERT INTO game.game_limits (
            game_id, currency_code, currency_type,
            min_bet, max_bet, default_bet, max_win,
            is_active, created_at, updated_at
        ) VALUES (
            p_game_id,
            UPPER(TRIM(v_elem->>'currency_code')),
            COALESCE((v_elem->>'currency_type')::SMALLINT, 1),
            (v_elem->>'min_bet')::DECIMAL(18,8),
            (v_elem->>'max_bet')::DECIMAL(18,8),
            (v_elem->>'default_bet')::DECIMAL(18,8),
            (v_elem->>'max_win')::DECIMAL(18,8),
            true,
            NOW(),
            NOW()
        )
        ON CONFLICT (game_id, currency_code) DO UPDATE SET
            currency_type = COALESCE((v_elem->>'currency_type')::SMALLINT, game.game_limits.currency_type),
            min_bet = (v_elem->>'min_bet')::DECIMAL(18,8),
            max_bet = (v_elem->>'max_bet')::DECIMAL(18,8),
            default_bet = (v_elem->>'default_bet')::DECIMAL(18,8),
            max_win = (v_elem->>'max_win')::DECIMAL(18,8),
            is_active = true,
            updated_at = NOW();

        v_synced_currencies := array_append(v_synced_currencies, UPPER(TRIM(v_elem->>'currency_code')));
    END LOOP;

    -- Artık desteklenmeyen limitleri soft delete
    UPDATE game.game_limits
    SET is_active = false, updated_at = NOW()
    WHERE game_id = p_game_id
      AND is_active = true
      AND currency_code != ALL(v_synced_currencies);
END;
$$;

COMMENT ON FUNCTION game.game_limits_sync(BIGINT, TEXT) IS 'Syncs per-game currency limits from Core to Tenant DB. Accepts TEXT→JSONB array. Limits not in payload are soft-deleted (is_active=false). Auth-agnostic.';

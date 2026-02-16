-- ================================================================
-- GAME_CURRENCY_LIMIT_SYNC: Per-game currency limit toplu upsert
-- ================================================================
-- Gateway sync veya BO admin tarafından çağrılır.
-- p_limits'te olmayan mevcut limitler is_active=false yapılır
-- (hard delete yok). Tekrar desteklenirse is_active=true döner.
-- ================================================================

DROP FUNCTION IF EXISTS catalog.game_currency_limit_sync(BIGINT, TEXT);

CREATE OR REPLACE FUNCTION catalog.game_currency_limit_sync(
    p_game_id BIGINT,
    p_limits TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
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

    IF NOT EXISTS(SELECT 1 FROM catalog.games WHERE id = p_game_id) THEN
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
        INSERT INTO catalog.game_currency_limits (
            game_id,
            currency_code,
            currency_type,
            min_bet,
            max_bet,
            default_bet,
            max_win,
            is_active,
            created_at,
            updated_at
        ) VALUES (
            p_game_id,
            UPPER(TRIM(v_elem->>'cc')),
            COALESCE((v_elem->>'ct')::SMALLINT, 1),
            (v_elem->>'min')::DECIMAL(18,8),
            (v_elem->>'max')::DECIMAL(18,8),
            (v_elem->>'def')::DECIMAL(18,8),
            (v_elem->>'win')::DECIMAL(18,8),
            true,
            NOW(),
            NOW()
        )
        ON CONFLICT (game_id, currency_code) DO UPDATE SET
            currency_type = COALESCE((v_elem->>'ct')::SMALLINT, catalog.game_currency_limits.currency_type),
            min_bet = (v_elem->>'min')::DECIMAL(18,8),
            max_bet = (v_elem->>'max')::DECIMAL(18,8),
            default_bet = (v_elem->>'def')::DECIMAL(18,8),
            max_win = (v_elem->>'win')::DECIMAL(18,8),
            is_active = true,
            updated_at = NOW();

        -- Senkronize edilen currency'leri takip et
        v_synced_currencies := array_append(v_synced_currencies, UPPER(TRIM(v_elem->>'cc')));
    END LOOP;

    -- Artık desteklenmeyen limitleri soft delete yap
    UPDATE catalog.game_currency_limits
    SET is_active = false, updated_at = NOW()
    WHERE game_id = p_game_id
      AND is_active = true
      AND currency_code != ALL(v_synced_currencies);
END;
$$;

COMMENT ON FUNCTION catalog.game_currency_limit_sync(BIGINT, TEXT) IS 'Bulk upsert per-game currency limits. Accepts TEXT→JSONB array with short keys (cc,ct,min,max,def,win). Limits not in payload are soft-deleted (is_active=false).';

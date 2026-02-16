-- ================================================================
-- GAME_BULK_UPSERT: Toplu oyun upsert (gateway sync veya CSV import)
-- ================================================================
-- p_provider_id ile provider doğrulanır.
-- p_games TEXT → JSONB array cast, tek transaction.
-- Her eleman (provider_id, external_game_id) bazlı UPSERT.
-- Normalize: LOWER(game_code), UPPER(game_type, volatility)
-- ================================================================

DROP FUNCTION IF EXISTS catalog.game_bulk_upsert(BIGINT, TEXT);

CREATE OR REPLACE FUNCTION catalog.game_bulk_upsert(
    p_provider_id BIGINT,
    p_games TEXT
)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_games JSONB;
    v_elem JSONB;
    v_count INTEGER := 0;
    v_code VARCHAR(100);
    v_type VARCHAR(50);
    v_volatility VARCHAR(20);
BEGIN
    -- Provider kontrolü
    IF p_provider_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.provider-id-required';
    END IF;

    IF NOT EXISTS(SELECT 1 FROM catalog.game_providers WHERE id = p_provider_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.game.provider-not-found';
    END IF;

    -- Veri kontrolü
    IF p_games IS NULL OR TRIM(p_games) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.data-required';
    END IF;

    v_games := p_games::JSONB;

    IF jsonb_typeof(v_games) != 'array' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.invalid-format';
    END IF;

    -- Her eleman için UPSERT
    FOR v_elem IN SELECT * FROM jsonb_array_elements(v_games)
    LOOP
        v_code := LOWER(TRIM(v_elem->>'game_code'));
        v_type := UPPER(TRIM(v_elem->>'game_type'));
        v_volatility := CASE WHEN v_elem->>'volatility' IS NOT NULL THEN UPPER(TRIM(v_elem->>'volatility')) ELSE NULL END;

        INSERT INTO catalog.games (
            provider_id, external_game_id, game_code, game_name, game_type,
            studio, description, game_subtype, volatility,
            categories, tags,
            rtp, hit_frequency, max_multiplier, paylines, reels, rows,
            thumbnail_url, background_url, logo_url, banner_url,
            min_bet, max_bet, default_bet,
            features, has_demo, has_jackpot, jackpot_type, has_bonus_buy,
            is_mobile, is_desktop, is_tablet, supported_platforms,
            supported_currencies, supported_cryptocurrencies, supported_languages, blocked_countries,
            certified_jurisdictions, age_restriction, sort_order, popularity_score, release_date,
            is_active, created_at, updated_at
        ) VALUES (
            p_provider_id,
            TRIM(v_elem->>'external_game_id'),
            v_code,
            TRIM(v_elem->>'game_name'),
            v_type,
            v_elem->>'studio',
            v_elem->>'description',
            v_elem->>'game_subtype',
            v_volatility,
            COALESCE((SELECT array_agg(x::VARCHAR(50)) FROM jsonb_array_elements_text(v_elem->'categories') x), '{}'),
            COALESCE((SELECT array_agg(x::VARCHAR(50)) FROM jsonb_array_elements_text(v_elem->'tags') x), '{}'),
            (v_elem->>'rtp')::DECIMAL(5,2),
            (v_elem->>'hit_frequency')::DECIMAL(5,2),
            (v_elem->>'max_multiplier')::DECIMAL(10,2),
            (v_elem->>'paylines')::INTEGER,
            (v_elem->>'reels')::INTEGER,
            (v_elem->>'rows')::INTEGER,
            v_elem->>'thumbnail_url',
            v_elem->>'background_url',
            v_elem->>'logo_url',
            v_elem->>'banner_url',
            (v_elem->>'min_bet')::DECIMAL(18,8),
            (v_elem->>'max_bet')::DECIMAL(18,8),
            (v_elem->>'default_bet')::DECIMAL(18,8),
            COALESCE((SELECT array_agg(x::VARCHAR(50)) FROM jsonb_array_elements_text(v_elem->'features') x), '{}'),
            COALESCE((v_elem->>'has_demo')::BOOLEAN, true),
            COALESCE((v_elem->>'has_jackpot')::BOOLEAN, false),
            v_elem->>'jackpot_type',
            COALESCE((v_elem->>'has_bonus_buy')::BOOLEAN, false),
            COALESCE((v_elem->>'is_mobile')::BOOLEAN, true),
            COALESCE((v_elem->>'is_desktop')::BOOLEAN, true),
            COALESCE((v_elem->>'is_tablet')::BOOLEAN, true),
            COALESCE((SELECT array_agg(x::VARCHAR(20)) FROM jsonb_array_elements_text(v_elem->'supported_platforms') x), '{web,mobile,app}'),
            COALESCE((SELECT array_agg(x::CHAR(3)) FROM jsonb_array_elements_text(v_elem->'supported_currencies') x), '{}'),
            COALESCE((SELECT array_agg(x::VARCHAR(20)) FROM jsonb_array_elements_text(v_elem->'supported_cryptocurrencies') x), '{}'),
            COALESCE((SELECT array_agg(x::CHAR(2)) FROM jsonb_array_elements_text(v_elem->'supported_languages') x), '{}'),
            COALESCE((SELECT array_agg(x::CHAR(2)) FROM jsonb_array_elements_text(v_elem->'blocked_countries') x), '{}'),
            COALESCE((SELECT array_agg(x::VARCHAR(20)) FROM jsonb_array_elements_text(v_elem->'certified_jurisdictions') x), '{}'),
            COALESCE((v_elem->>'age_restriction')::SMALLINT, 18),
            COALESCE((v_elem->>'sort_order')::INTEGER, 0),
            COALESCE((v_elem->>'popularity_score')::INTEGER, 0),
            (v_elem->>'release_date')::DATE,
            true,
            NOW(),
            NOW()
        )
        ON CONFLICT (provider_id, external_game_id) DO UPDATE SET
            game_code = v_code,
            game_name = TRIM(v_elem->>'game_name'),
            game_type = v_type,
            studio = COALESCE(v_elem->>'studio', catalog.games.studio),
            description = COALESCE(v_elem->>'description', catalog.games.description),
            game_subtype = COALESCE(v_elem->>'game_subtype', catalog.games.game_subtype),
            volatility = COALESCE(v_volatility, catalog.games.volatility),
            categories = COALESCE((SELECT array_agg(x::VARCHAR(50)) FROM jsonb_array_elements_text(v_elem->'categories') x), catalog.games.categories),
            tags = COALESCE((SELECT array_agg(x::VARCHAR(50)) FROM jsonb_array_elements_text(v_elem->'tags') x), catalog.games.tags),
            rtp = COALESCE((v_elem->>'rtp')::DECIMAL(5,2), catalog.games.rtp),
            hit_frequency = COALESCE((v_elem->>'hit_frequency')::DECIMAL(5,2), catalog.games.hit_frequency),
            max_multiplier = COALESCE((v_elem->>'max_multiplier')::DECIMAL(10,2), catalog.games.max_multiplier),
            paylines = COALESCE((v_elem->>'paylines')::INTEGER, catalog.games.paylines),
            reels = COALESCE((v_elem->>'reels')::INTEGER, catalog.games.reels),
            rows = COALESCE((v_elem->>'rows')::INTEGER, catalog.games.rows),
            thumbnail_url = COALESCE(v_elem->>'thumbnail_url', catalog.games.thumbnail_url),
            background_url = COALESCE(v_elem->>'background_url', catalog.games.background_url),
            logo_url = COALESCE(v_elem->>'logo_url', catalog.games.logo_url),
            banner_url = COALESCE(v_elem->>'banner_url', catalog.games.banner_url),
            min_bet = COALESCE((v_elem->>'min_bet')::DECIMAL(18,8), catalog.games.min_bet),
            max_bet = COALESCE((v_elem->>'max_bet')::DECIMAL(18,8), catalog.games.max_bet),
            default_bet = COALESCE((v_elem->>'default_bet')::DECIMAL(18,8), catalog.games.default_bet),
            features = COALESCE((SELECT array_agg(x::VARCHAR(50)) FROM jsonb_array_elements_text(v_elem->'features') x), catalog.games.features),
            has_demo = COALESCE((v_elem->>'has_demo')::BOOLEAN, catalog.games.has_demo),
            has_jackpot = COALESCE((v_elem->>'has_jackpot')::BOOLEAN, catalog.games.has_jackpot),
            jackpot_type = COALESCE(v_elem->>'jackpot_type', catalog.games.jackpot_type),
            has_bonus_buy = COALESCE((v_elem->>'has_bonus_buy')::BOOLEAN, catalog.games.has_bonus_buy),
            is_mobile = COALESCE((v_elem->>'is_mobile')::BOOLEAN, catalog.games.is_mobile),
            is_desktop = COALESCE((v_elem->>'is_desktop')::BOOLEAN, catalog.games.is_desktop),
            is_tablet = COALESCE((v_elem->>'is_tablet')::BOOLEAN, catalog.games.is_tablet),
            supported_platforms = COALESCE((SELECT array_agg(x::VARCHAR(20)) FROM jsonb_array_elements_text(v_elem->'supported_platforms') x), catalog.games.supported_platforms),
            supported_currencies = COALESCE((SELECT array_agg(x::CHAR(3)) FROM jsonb_array_elements_text(v_elem->'supported_currencies') x), catalog.games.supported_currencies),
            supported_cryptocurrencies = COALESCE((SELECT array_agg(x::VARCHAR(20)) FROM jsonb_array_elements_text(v_elem->'supported_cryptocurrencies') x), catalog.games.supported_cryptocurrencies),
            supported_languages = COALESCE((SELECT array_agg(x::CHAR(2)) FROM jsonb_array_elements_text(v_elem->'supported_languages') x), catalog.games.supported_languages),
            blocked_countries = COALESCE((SELECT array_agg(x::CHAR(2)) FROM jsonb_array_elements_text(v_elem->'blocked_countries') x), catalog.games.blocked_countries),
            certified_jurisdictions = COALESCE((SELECT array_agg(x::VARCHAR(20)) FROM jsonb_array_elements_text(v_elem->'certified_jurisdictions') x), catalog.games.certified_jurisdictions),
            age_restriction = COALESCE((v_elem->>'age_restriction')::SMALLINT, catalog.games.age_restriction),
            sort_order = COALESCE((v_elem->>'sort_order')::INTEGER, catalog.games.sort_order),
            popularity_score = COALESCE((v_elem->>'popularity_score')::INTEGER, catalog.games.popularity_score),
            release_date = COALESCE((v_elem->>'release_date')::DATE, catalog.games.release_date),
            provider_updated_at = NOW(),
            updated_at = NOW();

        v_count := v_count + 1;
    END LOOP;

    RETURN v_count;
END;
$$;

COMMENT ON FUNCTION catalog.game_bulk_upsert(BIGINT, TEXT) IS 'Bulk game upsert for gateway sync or CSV/Excel import. Accepts TEXT→JSONB array, performs (provider_id, external_game_id) based UPSERT in single transaction. Returns upserted count.';

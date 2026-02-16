-- ================================================================
-- GAME_UPSERT: Tekil oyun upsert (gateway sync veya BO admin)
-- ================================================================
-- (provider_id, external_game_id) bazlı UPSERT.
-- Gateway otomatik sync veya BO admin tekil ekleme için.
-- Normalize: LOWER(game_code), UPPER(game_type, volatility)
-- ================================================================

DROP FUNCTION IF EXISTS catalog.game_upsert(
    BIGINT, VARCHAR, VARCHAR, VARCHAR, VARCHAR,
    VARCHAR, TEXT, VARCHAR, VARCHAR, VARCHAR(50)[], VARCHAR(50)[],
    DECIMAL, VARCHAR, DECIMAL, DECIMAL, INTEGER, INTEGER, INTEGER,
    VARCHAR, VARCHAR, VARCHAR, VARCHAR,
    DECIMAL, DECIMAL, DECIMAL,
    VARCHAR(50)[], BOOLEAN, BOOLEAN, VARCHAR, BOOLEAN,
    BOOLEAN, BOOLEAN, BOOLEAN, VARCHAR(20)[],
    CHAR(3)[], VARCHAR(20)[], CHAR(2)[], CHAR(2)[],
    VARCHAR(20)[], SMALLINT, INTEGER, INTEGER, DATE
);

CREATE OR REPLACE FUNCTION catalog.game_upsert(
    p_provider_id BIGINT,
    p_external_game_id VARCHAR(100),
    p_game_code VARCHAR(100),
    p_game_name VARCHAR(255),
    p_game_type VARCHAR(50),
    -- Opsiyonel alanlar
    p_studio VARCHAR(100) DEFAULT NULL,
    p_description TEXT DEFAULT NULL,
    p_game_subtype VARCHAR(50) DEFAULT NULL,
    p_volatility VARCHAR(20) DEFAULT NULL,
    p_categories VARCHAR(50)[] DEFAULT NULL,
    p_tags VARCHAR(50)[] DEFAULT NULL,
    p_rtp DECIMAL(5,2) DEFAULT NULL,
    p_hit_frequency DECIMAL(5,2) DEFAULT NULL,
    p_max_multiplier DECIMAL(10,2) DEFAULT NULL,
    p_paylines INTEGER DEFAULT NULL,
    p_reels INTEGER DEFAULT NULL,
    p_rows INTEGER DEFAULT NULL,
    p_thumbnail_url VARCHAR(500) DEFAULT NULL,
    p_background_url VARCHAR(500) DEFAULT NULL,
    p_logo_url VARCHAR(500) DEFAULT NULL,
    p_banner_url VARCHAR(500) DEFAULT NULL,
    p_min_bet DECIMAL(18,8) DEFAULT NULL,
    p_max_bet DECIMAL(18,8) DEFAULT NULL,
    p_default_bet DECIMAL(18,8) DEFAULT NULL,
    p_features VARCHAR(50)[] DEFAULT NULL,
    p_has_demo BOOLEAN DEFAULT true,
    p_has_jackpot BOOLEAN DEFAULT false,
    p_jackpot_type VARCHAR(50) DEFAULT NULL,
    p_has_bonus_buy BOOLEAN DEFAULT false,
    p_is_mobile BOOLEAN DEFAULT true,
    p_is_desktop BOOLEAN DEFAULT true,
    p_is_tablet BOOLEAN DEFAULT true,
    p_supported_platforms VARCHAR(20)[] DEFAULT '{web,mobile,app}',
    p_supported_currencies CHAR(3)[] DEFAULT '{}',
    p_supported_cryptocurrencies VARCHAR(20)[] DEFAULT '{}',
    p_supported_languages CHAR(2)[] DEFAULT '{}',
    p_blocked_countries CHAR(2)[] DEFAULT '{}',
    p_certified_jurisdictions VARCHAR(20)[] DEFAULT '{}',
    p_age_restriction SMALLINT DEFAULT 18,
    p_sort_order INTEGER DEFAULT 0,
    p_popularity_score INTEGER DEFAULT 0,
    p_release_date DATE DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_game_id BIGINT;
    v_normalized_code VARCHAR(100);
    v_normalized_type VARCHAR(50);
    v_normalized_volatility VARCHAR(20);
BEGIN
    -- Zorunlu alan kontrolleri
    IF p_provider_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.provider-id-required';
    END IF;

    IF NOT EXISTS(SELECT 1 FROM catalog.game_providers WHERE id = p_provider_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.game.provider-not-found';
    END IF;

    IF p_external_game_id IS NULL OR TRIM(p_external_game_id) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.external-id-required';
    END IF;

    IF p_game_code IS NULL OR TRIM(p_game_code) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.code-required';
    END IF;

    IF p_game_name IS NULL OR TRIM(p_game_name) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.name-required';
    END IF;

    IF p_game_type IS NULL OR TRIM(p_game_type) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.type-required';
    END IF;

    -- Normalize
    v_normalized_code := LOWER(TRIM(p_game_code));
    v_normalized_type := UPPER(TRIM(p_game_type));
    v_normalized_volatility := CASE WHEN p_volatility IS NOT NULL THEN UPPER(TRIM(p_volatility)) ELSE NULL END;

    -- game_type validasyon
    IF v_normalized_type NOT IN ('SLOT', 'LIVE', 'TABLE', 'CRASH', 'SCRATCH', 'BINGO', 'VIRTUAL') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.invalid-type';
    END IF;

    -- UPSERT: (provider_id, external_game_id) bazlı
    INSERT INTO catalog.games (
        provider_id, external_game_id, game_code, game_name, game_type,
        studio, description, game_subtype, volatility, categories, tags,
        rtp, hit_frequency, max_multiplier, paylines, reels, rows,
        thumbnail_url, background_url, logo_url, banner_url,
        min_bet, max_bet, default_bet,
        features, has_demo, has_jackpot, jackpot_type, has_bonus_buy,
        is_mobile, is_desktop, is_tablet, supported_platforms,
        supported_currencies, supported_cryptocurrencies, supported_languages, blocked_countries,
        certified_jurisdictions, age_restriction, sort_order, popularity_score, release_date,
        is_active, created_at, updated_at
    ) VALUES (
        p_provider_id, TRIM(p_external_game_id), v_normalized_code, TRIM(p_game_name), v_normalized_type,
        p_studio, p_description, p_game_subtype, v_normalized_volatility, COALESCE(p_categories, '{}'), COALESCE(p_tags, '{}'),
        p_rtp, p_hit_frequency, p_max_multiplier, p_paylines, p_reels, p_rows,
        p_thumbnail_url, p_background_url, p_logo_url, p_banner_url,
        p_min_bet, p_max_bet, p_default_bet,
        COALESCE(p_features, '{}'), p_has_demo, p_has_jackpot, p_jackpot_type, p_has_bonus_buy,
        p_is_mobile, p_is_desktop, p_is_tablet, p_supported_platforms,
        p_supported_currencies, p_supported_cryptocurrencies, p_supported_languages, p_blocked_countries,
        p_certified_jurisdictions, p_age_restriction, p_sort_order, p_popularity_score, p_release_date,
        true, NOW(), NOW()
    )
    ON CONFLICT (provider_id, external_game_id) DO UPDATE SET
        game_code = v_normalized_code,
        game_name = TRIM(p_game_name),
        game_type = v_normalized_type,
        studio = COALESCE(p_studio, catalog.games.studio),
        description = COALESCE(p_description, catalog.games.description),
        game_subtype = COALESCE(p_game_subtype, catalog.games.game_subtype),
        volatility = COALESCE(v_normalized_volatility, catalog.games.volatility),
        categories = COALESCE(p_categories, catalog.games.categories),
        tags = COALESCE(p_tags, catalog.games.tags),
        rtp = COALESCE(p_rtp, catalog.games.rtp),
        hit_frequency = COALESCE(p_hit_frequency, catalog.games.hit_frequency),
        max_multiplier = COALESCE(p_max_multiplier, catalog.games.max_multiplier),
        paylines = COALESCE(p_paylines, catalog.games.paylines),
        reels = COALESCE(p_reels, catalog.games.reels),
        rows = COALESCE(p_rows, catalog.games.rows),
        thumbnail_url = COALESCE(p_thumbnail_url, catalog.games.thumbnail_url),
        background_url = COALESCE(p_background_url, catalog.games.background_url),
        logo_url = COALESCE(p_logo_url, catalog.games.logo_url),
        banner_url = COALESCE(p_banner_url, catalog.games.banner_url),
        min_bet = COALESCE(p_min_bet, catalog.games.min_bet),
        max_bet = COALESCE(p_max_bet, catalog.games.max_bet),
        default_bet = COALESCE(p_default_bet, catalog.games.default_bet),
        features = COALESCE(p_features, catalog.games.features),
        has_demo = p_has_demo,
        has_jackpot = p_has_jackpot,
        jackpot_type = COALESCE(p_jackpot_type, catalog.games.jackpot_type),
        has_bonus_buy = p_has_bonus_buy,
        is_mobile = p_is_mobile,
        is_desktop = p_is_desktop,
        is_tablet = p_is_tablet,
        supported_platforms = p_supported_platforms,
        supported_currencies = p_supported_currencies,
        supported_cryptocurrencies = p_supported_cryptocurrencies,
        supported_languages = p_supported_languages,
        blocked_countries = p_blocked_countries,
        certified_jurisdictions = p_certified_jurisdictions,
        age_restriction = p_age_restriction,
        sort_order = p_sort_order,
        popularity_score = p_popularity_score,
        release_date = COALESCE(p_release_date, catalog.games.release_date),
        provider_updated_at = NOW(),
        updated_at = NOW()
    RETURNING id INTO v_game_id;

    RETURN v_game_id;
END;
$$;

COMMENT ON FUNCTION catalog.game_upsert IS 'Single game upsert by (provider_id, external_game_id). For gateway sync or BO admin. Normalizes game_code (lowercase), game_type and volatility (uppercase). Returns game id.';

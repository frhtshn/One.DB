-- ================================================================
-- GAME_GET: Tekil oyun detay (JOIN game_providers)
-- ================================================================
-- Tüm oyun bilgilerini provider adı ile birlikte döner.
-- ================================================================

DROP FUNCTION IF EXISTS catalog.game_get(BIGINT);

CREATE OR REPLACE FUNCTION catalog.game_get(
    p_id BIGINT
)
RETURNS TABLE(
    id BIGINT,
    provider_id BIGINT,
    provider_code VARCHAR(50),
    provider_name VARCHAR(255),
    external_game_id VARCHAR(100),
    game_code VARCHAR(100),
    game_name VARCHAR(255),
    studio VARCHAR(100),
    description TEXT,
    game_type VARCHAR(50),
    game_subtype VARCHAR(50),
    categories VARCHAR(50)[],
    tags VARCHAR(50)[],
    rtp DECIMAL(5,2),
    hit_frequency DECIMAL(5,2),
    volatility VARCHAR(20),
    max_multiplier DECIMAL(10,2),
    paylines INTEGER,
    reels INTEGER,
    rows INTEGER,
    thumbnail_url VARCHAR(500),
    background_url VARCHAR(500),
    logo_url VARCHAR(500),
    banner_url VARCHAR(500),
    min_bet DECIMAL(18,8),
    max_bet DECIMAL(18,8),
    default_bet DECIMAL(18,8),
    features VARCHAR(50)[],
    has_demo BOOLEAN,
    has_jackpot BOOLEAN,
    jackpot_type VARCHAR(50),
    has_bonus_buy BOOLEAN,
    is_mobile BOOLEAN,
    is_desktop BOOLEAN,
    is_tablet BOOLEAN,
    supported_platforms VARCHAR(20)[],
    supported_currencies CHAR(3)[],
    supported_cryptocurrencies VARCHAR(20)[],
    supported_languages CHAR(2)[],
    blocked_countries CHAR(2)[],
    certified_jurisdictions VARCHAR(20)[],
    age_restriction SMALLINT,
    sort_order INTEGER,
    popularity_score INTEGER,
    release_date DATE,
    provider_updated_at TIMESTAMPTZ,
    is_active BOOLEAN,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    -- Varlık kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.id-required';
    END IF;

    IF NOT EXISTS(SELECT 1 FROM catalog.games WHERE catalog.games.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.game.not-found';
    END IF;

    RETURN QUERY
    SELECT
        g.id,
        g.provider_id,
        gp.provider_code,
        gp.provider_name,
        g.external_game_id,
        g.game_code,
        g.game_name,
        g.studio,
        g.description,
        g.game_type,
        g.game_subtype,
        g.categories,
        g.tags,
        g.rtp,
        g.hit_frequency,
        g.volatility,
        g.max_multiplier,
        g.paylines,
        g.reels,
        g.rows,
        g.thumbnail_url,
        g.background_url,
        g.logo_url,
        g.banner_url,
        g.min_bet,
        g.max_bet,
        g.default_bet,
        g.features,
        g.has_demo,
        g.has_jackpot,
        g.jackpot_type,
        g.has_bonus_buy,
        g.is_mobile,
        g.is_desktop,
        g.is_tablet,
        g.supported_platforms,
        g.supported_currencies,
        g.supported_cryptocurrencies,
        g.supported_languages,
        g.blocked_countries,
        g.certified_jurisdictions,
        g.age_restriction,
        g.sort_order,
        g.popularity_score,
        g.release_date,
        g.provider_updated_at,
        g.is_active,
        g.created_at,
        g.updated_at
    FROM catalog.games g
    JOIN catalog.game_providers gp ON gp.id = g.provider_id
    WHERE g.id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.game_get(BIGINT) IS 'Returns single game detail with provider info. Used by backend for sync orchestration and BO admin detail view.';

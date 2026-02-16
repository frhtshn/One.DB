-- ================================================================
-- GAME_UPDATE: BO metadata güncelleme (COALESCE pattern)
-- ================================================================
-- NULL = mevcut değeri koru. Soft delete: p_is_active = FALSE.
-- ================================================================

DROP FUNCTION IF EXISTS catalog.game_update(
    BIGINT, VARCHAR, VARCHAR, VARCHAR,
    VARCHAR, TEXT, VARCHAR, VARCHAR, VARCHAR(50)[], VARCHAR(50)[],
    DECIMAL, DECIMAL, DECIMAL, INTEGER, INTEGER, INTEGER,
    VARCHAR, VARCHAR, VARCHAR, VARCHAR,
    DECIMAL, DECIMAL, DECIMAL,
    VARCHAR(50)[], BOOLEAN, BOOLEAN, VARCHAR, BOOLEAN,
    BOOLEAN, BOOLEAN, BOOLEAN, VARCHAR(20)[],
    CHAR(3)[], VARCHAR(20)[], CHAR(2)[], CHAR(2)[],
    VARCHAR(20)[], SMALLINT, INTEGER, INTEGER, DATE, BOOLEAN
);

CREATE OR REPLACE FUNCTION catalog.game_update(
    p_id BIGINT,
    p_game_code VARCHAR(100) DEFAULT NULL,
    p_game_name VARCHAR(255) DEFAULT NULL,
    p_game_type VARCHAR(50) DEFAULT NULL,
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
    p_has_demo BOOLEAN DEFAULT NULL,
    p_has_jackpot BOOLEAN DEFAULT NULL,
    p_jackpot_type VARCHAR(50) DEFAULT NULL,
    p_has_bonus_buy BOOLEAN DEFAULT NULL,
    p_is_mobile BOOLEAN DEFAULT NULL,
    p_is_desktop BOOLEAN DEFAULT NULL,
    p_is_tablet BOOLEAN DEFAULT NULL,
    p_supported_platforms VARCHAR(20)[] DEFAULT NULL,
    p_supported_currencies CHAR(3)[] DEFAULT NULL,
    p_supported_cryptocurrencies VARCHAR(20)[] DEFAULT NULL,
    p_supported_languages CHAR(2)[] DEFAULT NULL,
    p_blocked_countries CHAR(2)[] DEFAULT NULL,
    p_certified_jurisdictions VARCHAR(20)[] DEFAULT NULL,
    p_age_restriction SMALLINT DEFAULT NULL,
    p_sort_order INTEGER DEFAULT NULL,
    p_popularity_score INTEGER DEFAULT NULL,
    p_release_date DATE DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.id-required';
    END IF;

    IF NOT EXISTS(SELECT 1 FROM catalog.games WHERE id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.game.not-found';
    END IF;

    -- game_type validasyon (sadece geçilmişse)
    IF p_game_type IS NOT NULL AND UPPER(TRIM(p_game_type)) NOT IN ('SLOT', 'LIVE', 'TABLE', 'CRASH', 'SCRATCH', 'BINGO', 'VIRTUAL') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.game.invalid-type';
    END IF;

    -- COALESCE güncelleme
    UPDATE catalog.games SET
        game_code = COALESCE(LOWER(TRIM(p_game_code)), game_code),
        game_name = COALESCE(TRIM(p_game_name), game_name),
        game_type = COALESCE(UPPER(TRIM(p_game_type)), game_type),
        studio = COALESCE(p_studio, studio),
        description = COALESCE(p_description, description),
        game_subtype = COALESCE(p_game_subtype, game_subtype),
        volatility = COALESCE(UPPER(TRIM(p_volatility)), volatility),
        categories = COALESCE(p_categories, categories),
        tags = COALESCE(p_tags, tags),
        rtp = COALESCE(p_rtp, rtp),
        hit_frequency = COALESCE(p_hit_frequency, hit_frequency),
        max_multiplier = COALESCE(p_max_multiplier, max_multiplier),
        paylines = COALESCE(p_paylines, paylines),
        reels = COALESCE(p_reels, reels),
        rows = COALESCE(p_rows, rows),
        thumbnail_url = COALESCE(p_thumbnail_url, thumbnail_url),
        background_url = COALESCE(p_background_url, background_url),
        logo_url = COALESCE(p_logo_url, logo_url),
        banner_url = COALESCE(p_banner_url, banner_url),
        min_bet = COALESCE(p_min_bet, min_bet),
        max_bet = COALESCE(p_max_bet, max_bet),
        default_bet = COALESCE(p_default_bet, default_bet),
        features = COALESCE(p_features, features),
        has_demo = COALESCE(p_has_demo, has_demo),
        has_jackpot = COALESCE(p_has_jackpot, has_jackpot),
        jackpot_type = COALESCE(p_jackpot_type, jackpot_type),
        has_bonus_buy = COALESCE(p_has_bonus_buy, has_bonus_buy),
        is_mobile = COALESCE(p_is_mobile, is_mobile),
        is_desktop = COALESCE(p_is_desktop, is_desktop),
        is_tablet = COALESCE(p_is_tablet, is_tablet),
        supported_platforms = COALESCE(p_supported_platforms, supported_platforms),
        supported_currencies = COALESCE(p_supported_currencies, supported_currencies),
        supported_cryptocurrencies = COALESCE(p_supported_cryptocurrencies, supported_cryptocurrencies),
        supported_languages = COALESCE(p_supported_languages, supported_languages),
        blocked_countries = COALESCE(p_blocked_countries, blocked_countries),
        certified_jurisdictions = COALESCE(p_certified_jurisdictions, certified_jurisdictions),
        age_restriction = COALESCE(p_age_restriction, age_restriction),
        sort_order = COALESCE(p_sort_order, sort_order),
        popularity_score = COALESCE(p_popularity_score, popularity_score),
        release_date = COALESCE(p_release_date, release_date),
        is_active = COALESCE(p_is_active, is_active),
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.game_update IS 'Updates game metadata using COALESCE pattern (NULL=keep current). Soft delete via p_is_active=false. Normalizes game_code (lowercase), game_type and volatility (uppercase).';

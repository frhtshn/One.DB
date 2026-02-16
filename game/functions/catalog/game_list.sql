-- ================================================================
-- GAME_LIST: Filtreli oyun listesi
-- ================================================================
-- Provider, tip, durum ve metin filtresi destekler.
-- Sayfalama (LIMIT/OFFSET) ile döner.
-- ================================================================

DROP FUNCTION IF EXISTS catalog.game_list(BIGINT, VARCHAR, BOOLEAN, TEXT, INTEGER, INTEGER);

CREATE OR REPLACE FUNCTION catalog.game_list(
    p_provider_id BIGINT DEFAULT NULL,
    p_game_type VARCHAR(50) DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL,
    p_search TEXT DEFAULT NULL,
    p_limit INTEGER DEFAULT 50,
    p_offset INTEGER DEFAULT 0
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
    game_type VARCHAR(50),
    game_subtype VARCHAR(50),
    categories VARCHAR(50)[],
    tags VARCHAR(50)[],
    rtp DECIMAL(5,2),
    volatility VARCHAR(20),
    thumbnail_url VARCHAR(500),
    has_demo BOOLEAN,
    has_jackpot BOOLEAN,
    has_bonus_buy BOOLEAN,
    is_mobile BOOLEAN,
    is_desktop BOOLEAN,
    sort_order INTEGER,
    popularity_score INTEGER,
    is_active BOOLEAN,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    total_count BIGINT
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
DECLARE
    v_total BIGINT;
BEGIN
    -- Toplam sayı
    SELECT COUNT(*) INTO v_total
    FROM catalog.games g
    WHERE (p_provider_id IS NULL OR g.provider_id = p_provider_id)
      AND (p_game_type IS NULL OR g.game_type = UPPER(TRIM(p_game_type)))
      AND (p_is_active IS NULL OR g.is_active = p_is_active)
      AND (p_search IS NULL OR
           g.game_name ILIKE '%' || p_search || '%' OR
           g.game_code ILIKE '%' || p_search || '%' OR
           g.studio ILIKE '%' || p_search || '%');

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
        g.game_type,
        g.game_subtype,
        g.categories,
        g.tags,
        g.rtp,
        g.volatility,
        g.thumbnail_url,
        g.has_demo,
        g.has_jackpot,
        g.has_bonus_buy,
        g.is_mobile,
        g.is_desktop,
        g.sort_order,
        g.popularity_score,
        g.is_active,
        g.created_at,
        g.updated_at,
        v_total
    FROM catalog.games g
    JOIN catalog.game_providers gp ON gp.id = g.provider_id
    WHERE (p_provider_id IS NULL OR g.provider_id = p_provider_id)
      AND (p_game_type IS NULL OR g.game_type = UPPER(TRIM(p_game_type)))
      AND (p_is_active IS NULL OR g.is_active = p_is_active)
      AND (p_search IS NULL OR
           g.game_name ILIKE '%' || p_search || '%' OR
           g.game_code ILIKE '%' || p_search || '%' OR
           g.studio ILIKE '%' || p_search || '%')
    ORDER BY g.sort_order ASC, g.popularity_score DESC, g.id ASC
    LIMIT p_limit OFFSET p_offset;
END;
$$;

COMMENT ON FUNCTION catalog.game_list IS 'Returns filtered game list with provider info. Supports filtering by provider, game_type, is_active, and text search. Includes total_count for pagination.';

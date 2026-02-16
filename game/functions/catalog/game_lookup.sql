-- ================================================================
-- GAME_LOOKUP: Dropdown için hafif oyun listesi
-- ================================================================
-- Sadece id, code, name, provider, type döner.
-- Aktif oyunlar varsayılan.
-- ================================================================

DROP FUNCTION IF EXISTS catalog.game_lookup(BIGINT, VARCHAR, TEXT);

CREATE OR REPLACE FUNCTION catalog.game_lookup(
    p_provider_id BIGINT DEFAULT NULL,
    p_game_type VARCHAR(50) DEFAULT NULL,
    p_search TEXT DEFAULT NULL
)
RETURNS TABLE(
    id BIGINT,
    game_code VARCHAR(100),
    game_name VARCHAR(255),
    provider_id BIGINT,
    provider_code VARCHAR(50),
    game_type VARCHAR(50)
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        g.id,
        g.game_code,
        g.game_name,
        g.provider_id,
        gp.provider_code,
        g.game_type
    FROM catalog.games g
    JOIN catalog.game_providers gp ON gp.id = g.provider_id
    WHERE g.is_active = true
      AND (p_provider_id IS NULL OR g.provider_id = p_provider_id)
      AND (p_game_type IS NULL OR g.game_type = UPPER(TRIM(p_game_type)))
      AND (p_search IS NULL OR
           g.game_name ILIKE '%' || p_search || '%' OR
           g.game_code ILIKE '%' || p_search || '%')
    ORDER BY g.game_name ASC;
END;
$$;

COMMENT ON FUNCTION catalog.game_lookup IS 'Lightweight game list for dropdowns. Returns only id, code, name, provider, type. Active games only.';

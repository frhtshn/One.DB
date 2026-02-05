-- ================================================================
-- THEME_LIST: Temaları listeler
-- Opsiyonel is_active ve is_premium filtresi
-- ================================================================

DROP FUNCTION IF EXISTS catalog.theme_list(BOOLEAN, BOOLEAN);

CREATE OR REPLACE FUNCTION catalog.theme_list(
    p_is_active BOOLEAN DEFAULT NULL,
    p_is_premium BOOLEAN DEFAULT NULL
)
RETURNS TABLE(
    id INT,
    code VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    version VARCHAR(20),
    thumbnail_url VARCHAR(255),
    default_config JSONB,
    is_active BOOLEAN,
    is_premium BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        t.id,
        t.code,
        t.name,
        t.description,
        t.version,
        t.thumbnail_url,
        t.default_config,
        t.is_active,
        t.is_premium,
        t.created_at,
        t.updated_at
    FROM catalog.themes t
    WHERE (p_is_active IS NULL OR t.is_active = p_is_active)
      AND (p_is_premium IS NULL OR t.is_premium = p_is_premium)
    ORDER BY t.name;
END;
$$;

COMMENT ON FUNCTION catalog.theme_list IS 'Lists themes.';

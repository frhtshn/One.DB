-- ================================================================
-- THEME_LOOKUP: Theme dropdown için basit liste
-- ================================================================

DROP FUNCTION IF EXISTS catalog.theme_lookup();

CREATE OR REPLACE FUNCTION catalog.theme_lookup()
RETURNS TABLE(
    id INT,
    code VARCHAR(50),
    name VARCHAR(100),
    is_active BOOLEAN,
    is_premium BOOLEAN
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
        t.is_active,
        t.is_premium
    FROM catalog.themes t
    ORDER BY t.name;
END;
$$;

COMMENT ON FUNCTION catalog.theme_lookup() IS 'Returns theme list for dropdowns.';

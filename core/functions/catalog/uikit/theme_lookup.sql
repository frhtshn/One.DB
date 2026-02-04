-- ================================================================
-- THEME_LOOKUP: Theme dropdown için basit liste
-- SuperAdmin erişebilir (theme_list ile tutarlı)
-- ================================================================

DROP FUNCTION IF EXISTS catalog.theme_lookup();
DROP FUNCTION IF EXISTS catalog.theme_lookup(BIGINT);

CREATE OR REPLACE FUNCTION catalog.theme_lookup(
    p_caller_id BIGINT
)
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
    -- SuperAdmin check
    PERFORM security.user_assert_superadmin(p_caller_id);

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

COMMENT ON FUNCTION catalog.theme_lookup(BIGINT) IS 'Returns theme list for dropdowns. SuperAdmin only.';

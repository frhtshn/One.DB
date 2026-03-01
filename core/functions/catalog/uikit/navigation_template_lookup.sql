-- ================================================================
-- NAVIGATION_TEMPLATE_LOOKUP: Template dropdown için basit liste
-- ================================================================

DROP FUNCTION IF EXISTS catalog.navigation_template_lookup();

CREATE OR REPLACE FUNCTION catalog.navigation_template_lookup()
RETURNS TABLE(
    id INT,
    code VARCHAR(50),
    name VARCHAR(100),
    is_active BOOLEAN
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = catalog, pg_temp
AS $$
BEGIN
    RETURN QUERY
    SELECT
        nt.id,
        nt.code,
        nt.name,
        nt.is_active
    FROM catalog.navigation_templates nt
    WHERE nt.status = 1
    ORDER BY nt.name;
END;
$$;

COMMENT ON FUNCTION catalog.navigation_template_lookup() IS
'Returns navigation template list for dropdowns.
Used in client_navigation_init_from_template for template selection.';

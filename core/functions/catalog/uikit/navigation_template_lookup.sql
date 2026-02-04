-- ================================================================
-- NAVIGATION_TEMPLATE_LOOKUP: Template dropdown için basit liste
-- Platform Admin erişebilir (init_from_template için)
-- ================================================================

DROP FUNCTION IF EXISTS catalog.navigation_template_lookup();
DROP FUNCTION IF EXISTS catalog.navigation_template_lookup(BIGINT);

CREATE OR REPLACE FUNCTION catalog.navigation_template_lookup(
    p_caller_id BIGINT
)
RETURNS TABLE(
    id INT,
    code VARCHAR(50),
    name VARCHAR(100),
    is_active BOOLEAN
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = catalog, security, pg_temp
AS $$
BEGIN
    -- Platform Admin check (superadmin or admin)
    PERFORM security.user_assert_platform_admin(p_caller_id);

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

COMMENT ON FUNCTION catalog.navigation_template_lookup(BIGINT) IS
'Returns navigation template list for dropdowns. Platform Admin only.
Used in tenant_navigation_init_from_template for template selection.';

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
    -- Platform Admin kontrolü (superadmin veya admin)
    IF NOT EXISTS(
        SELECT 1 FROM security.user_roles ur
        JOIN security.roles r ON ur.role_id = r.id
        WHERE ur.user_id = p_caller_id
          AND ur.tenant_id IS NULL
          AND r.is_platform_role = TRUE
          AND r.status = 1
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

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

-- ================================================================
-- NAVIGATION_TEMPLATE_LIST: Navigasyon şablonlarını listeler
-- ================================================================

DROP FUNCTION IF EXISTS catalog.navigation_template_list(BOOLEAN);

CREATE OR REPLACE FUNCTION catalog.navigation_template_list(
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS TABLE(
    id INT,
    code VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    is_active BOOLEAN,
    is_default BOOLEAN,
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
        nt.id,
        nt.code,
        nt.name,
        nt.description,
        nt.is_active,
        nt.is_default,
        nt.created_at,
        nt.updated_at
    FROM catalog.navigation_templates nt
    WHERE (p_is_active IS NULL OR nt.is_active = p_is_active)
    ORDER BY nt.is_default DESC, nt.name;
END;
$$;

COMMENT ON FUNCTION catalog.navigation_template_list IS 'Lists navigation templates.';

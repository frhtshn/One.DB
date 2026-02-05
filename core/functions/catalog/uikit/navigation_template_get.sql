-- ================================================================
-- NAVIGATION_TEMPLATE_GET: Tekil navigasyon şablonu getirir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.navigation_template_get(INT);

CREATE OR REPLACE FUNCTION catalog.navigation_template_get(
    p_id INT
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
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.navigation-template.id-required';
    END IF;

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
    WHERE nt.id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.navigation-template.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION catalog.navigation_template_get IS 'Gets a single navigation template by ID.';

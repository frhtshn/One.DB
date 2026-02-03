-- ================================================================
-- NAVIGATION_TEMPLATE_GET: Tekil navigasyon şablonu getirir
-- SuperAdmin erişebilir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.navigation_template_get(BIGINT, INT);

CREATE OR REPLACE FUNCTION catalog.navigation_template_get(
    p_caller_id BIGINT,
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
    -- SuperAdmin kontrolü
    IF NOT EXISTS(
        SELECT 1 FROM security.user_roles ur
        JOIN security.roles r ON ur.role_id = r.id
        WHERE ur.user_id = p_caller_id
          AND ur.tenant_id IS NULL
          AND r.code = 'superadmin'
          AND r.status = 1
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
    END IF;

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

COMMENT ON FUNCTION catalog.navigation_template_get IS 'Gets a single navigation template by ID. SuperAdmin only.';

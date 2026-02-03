-- ================================================================
-- UI_POSITION_GET: Tekil UI pozisyonu getirir
-- SuperAdmin erişebilir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.ui_position_get(BIGINT, INT);

CREATE OR REPLACE FUNCTION catalog.ui_position_get(
    p_caller_id BIGINT,
    p_id INT
)
RETURNS TABLE(
    id INT,
    code VARCHAR(50),
    name VARCHAR(100),
    is_global BOOLEAN,
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
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.ui-position.id-required';
    END IF;

    RETURN QUERY
    SELECT
        up.id,
        up.code,
        up.name,
        up.is_global,
        up.created_at,
        up.updated_at
    FROM catalog.ui_positions up
    WHERE up.id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.ui-position.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION catalog.ui_position_get IS 'Gets a single UI position by ID. SuperAdmin only.';

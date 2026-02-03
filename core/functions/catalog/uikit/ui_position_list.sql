-- ================================================================
-- UI_POSITION_LIST: UI pozisyonlarını listeler
-- SuperAdmin erişebilir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.ui_position_list(BIGINT, BOOLEAN);

CREATE OR REPLACE FUNCTION catalog.ui_position_list(
    p_caller_id BIGINT,
    p_is_global BOOLEAN DEFAULT NULL
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

    RETURN QUERY
    SELECT
        up.id,
        up.code,
        up.name,
        up.is_global,
        up.created_at,
        up.updated_at
    FROM catalog.ui_positions up
    WHERE (p_is_global IS NULL OR up.is_global = p_is_global)
    ORDER BY up.name;
END;
$$;

COMMENT ON FUNCTION catalog.ui_position_list IS 'Lists UI positions. SuperAdmin only.';

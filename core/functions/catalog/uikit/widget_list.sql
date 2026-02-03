-- ================================================================
-- WIDGET_LIST: Widget'ları listeler
-- SuperAdmin erişebilir
-- Opsiyonel category ve is_active filtresi
-- ================================================================

DROP FUNCTION IF EXISTS catalog.widget_list(BIGINT, VARCHAR, BOOLEAN);

CREATE OR REPLACE FUNCTION catalog.widget_list(
    p_caller_id BIGINT,
    p_category VARCHAR(30) DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS TABLE(
    id INT,
    code VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    category VARCHAR(30),
    component_name VARCHAR(100),
    default_props JSONB,
    is_active BOOLEAN,
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
        w.id,
        w.code,
        w.name,
        w.description,
        w.category,
        w.component_name,
        w.default_props,
        w.is_active,
        w.created_at,
        w.updated_at
    FROM catalog.widgets w
    WHERE (p_category IS NULL OR w.category = p_category)
      AND (p_is_active IS NULL OR w.is_active = p_is_active)
    ORDER BY w.category, w.name;
END;
$$;

COMMENT ON FUNCTION catalog.widget_list IS 'Lists widgets. SuperAdmin only.';

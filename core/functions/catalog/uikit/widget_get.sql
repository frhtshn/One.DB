-- ================================================================
-- WIDGET_GET: Tekil widget getirir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.widget_get(INT);

CREATE OR REPLACE FUNCTION catalog.widget_get(
    p_id INT
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
    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.widget.id-required';
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
    WHERE w.id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.widget.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION catalog.widget_get IS 'Gets a single widget by ID.';

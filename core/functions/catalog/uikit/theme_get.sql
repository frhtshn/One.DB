-- ================================================================
-- THEME_GET: Tekil tema getirir
-- SuperAdmin erişebilir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.theme_get(BIGINT, INT);

CREATE OR REPLACE FUNCTION catalog.theme_get(
    p_caller_id BIGINT,
    p_id INT
)
RETURNS TABLE(
    id INT,
    code VARCHAR(50),
    name VARCHAR(100),
    description TEXT,
    version VARCHAR(20),
    thumbnail_url VARCHAR(255),
    default_config JSONB,
    is_active BOOLEAN,
    is_premium BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    -- SuperAdmin check
    PERFORM security.user_assert_superadmin(p_caller_id);

    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.theme.id-required';
    END IF;

    RETURN QUERY
    SELECT
        t.id,
        t.code,
        t.name,
        t.description,
        t.version,
        t.thumbnail_url,
        t.default_config,
        t.is_active,
        t.is_premium,
        t.created_at,
        t.updated_at
    FROM catalog.themes t
    WHERE t.id = p_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.theme.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION catalog.theme_get IS 'Gets a single theme by ID. SuperAdmin only.';

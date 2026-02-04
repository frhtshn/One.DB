-- ================================================================
-- PROVIDER_GET: Tekil provider getirir
-- Sadece SuperAdmin erişebilir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.provider_get(BIGINT);
DROP FUNCTION IF EXISTS catalog.provider_get(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION catalog.provider_get(
    p_caller_id BIGINT,
    p_id BIGINT
)
RETURNS TABLE(
    id BIGINT,
    provider_type_id BIGINT,
    provider_type_code VARCHAR(30),
    provider_type_name VARCHAR(100),
    provider_code VARCHAR(50),
    provider_name VARCHAR(255),
    is_active BOOLEAN,
    created_at TIMESTAMP
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
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.provider.id-required';
    END IF;

    RETURN QUERY
    SELECT
        p.id,
        p.provider_type_id,
        pt.provider_type_code,
        pt.provider_type_name,
        p.provider_code,
        p.provider_name,
        p.is_active,
        p.created_at
    FROM catalog.providers p
    JOIN catalog.provider_types pt ON pt.id = p.provider_type_id
    WHERE p.id = p_id;

    -- Bulunamadı kontrolü
    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.provider.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION catalog.provider_get IS 'Gets a single provider by ID. SuperAdmin only.';

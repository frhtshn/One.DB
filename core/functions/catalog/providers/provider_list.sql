-- ================================================================
-- PROVIDER_LIST: Provider'ları listeler
-- Sadece SuperAdmin erişebilir
-- Opsiyonel type_id ve is_active filtresi
-- ================================================================

DROP FUNCTION IF EXISTS catalog.provider_list(BIGINT, BOOLEAN);
DROP FUNCTION IF EXISTS catalog.provider_list(BIGINT, BIGINT, BOOLEAN);

CREATE OR REPLACE FUNCTION catalog.provider_list(
    p_caller_id BIGINT,
    p_type_id BIGINT DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
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
    WHERE (p_type_id IS NULL OR p.provider_type_id = p_type_id)
      AND (p_is_active IS NULL OR p.is_active = p_is_active)
    ORDER BY pt.provider_type_name, p.provider_name;
END;
$$;

COMMENT ON FUNCTION catalog.provider_list IS 'Lists providers with optional filters. SuperAdmin only.';

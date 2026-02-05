-- ================================================================
-- PROVIDER_LOOKUP: Provider dropdown icin basit liste
-- Opsiyonel provider_type_id filtresi
-- ================================================================

DROP FUNCTION IF EXISTS catalog.provider_lookup(BIGINT);

CREATE OR REPLACE FUNCTION catalog.provider_lookup(
    p_type_id BIGINT DEFAULT NULL
)
RETURNS TABLE(
    id BIGINT,
    code VARCHAR(50),
    name VARCHAR(255),
    type_id BIGINT,
    type_code VARCHAR(30),
    type_name VARCHAR(100),
    is_active BOOLEAN
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.provider_code AS code,
        p.provider_name AS name,
        p.provider_type_id AS type_id,
        pt.provider_type_code AS type_code,
        pt.provider_type_name AS type_name,
        p.is_active
    FROM catalog.providers p
    JOIN catalog.provider_types pt ON pt.id = p.provider_type_id
    WHERE (p_type_id IS NULL OR p.provider_type_id = p_type_id)
    ORDER BY pt.provider_type_name, p.provider_name;
END;
$$;

COMMENT ON FUNCTION catalog.provider_lookup(BIGINT) IS 'Returns provider list for dropdowns. Optional type_id filter.';

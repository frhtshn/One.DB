-- ================================================================
-- PROVIDER_TYPE_LOOKUP: Provider tipi dropdown icin basit liste
-- ================================================================

DROP FUNCTION IF EXISTS catalog.provider_type_lookup();

CREATE OR REPLACE FUNCTION catalog.provider_type_lookup()
RETURNS TABLE(
    id BIGINT,
    code VARCHAR(30),
    name VARCHAR(100),
    is_active BOOLEAN
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        pt.id,
        pt.provider_type_code AS code,
        pt.provider_type_name AS name,
        TRUE AS is_active  -- provider_types tablosunda is_active yok
    FROM catalog.provider_types pt
    ORDER BY pt.provider_type_name;
END;
$$;

COMMENT ON FUNCTION catalog.provider_type_lookup() IS 'Returns provider type list for dropdowns.';

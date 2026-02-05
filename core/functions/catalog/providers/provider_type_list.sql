-- ================================================================
-- PROVIDER_TYPE_LIST: Tum provider tiplerini listeler
-- ================================================================

DROP FUNCTION IF EXISTS catalog.provider_type_list();

CREATE OR REPLACE FUNCTION catalog.provider_type_list()
RETURNS TABLE(
    id BIGINT,
    provider_type_code VARCHAR(30),
    provider_type_name VARCHAR(100),
    created_at TIMESTAMP
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        pt.id,
        pt.provider_type_code,
        pt.provider_type_name,
        pt.created_at
    FROM catalog.provider_types pt
    ORDER BY pt.provider_type_name;
END;
$$;

COMMENT ON FUNCTION catalog.provider_type_list IS 'Lists all provider types.';

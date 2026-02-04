-- ================================================================
-- PROVIDER_TYPE_LOOKUP: Provider tipi dropdown için basit liste
-- SuperAdmin erişebilir (provider_type_list ile tutarlı)
-- ================================================================

DROP FUNCTION IF EXISTS catalog.provider_type_lookup();
DROP FUNCTION IF EXISTS catalog.provider_type_lookup(BIGINT);

CREATE OR REPLACE FUNCTION catalog.provider_type_lookup(
    p_caller_id BIGINT
)
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
    -- SuperAdmin check
    PERFORM security.user_assert_superadmin(p_caller_id);

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

COMMENT ON FUNCTION catalog.provider_type_lookup(BIGINT) IS 'Returns provider type list for dropdowns. SuperAdmin only.';

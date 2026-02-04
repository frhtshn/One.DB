-- ================================================================
-- JURISDICTION_LOOKUP: Jurisdiction dropdown için basit liste
-- Platform Admin (SuperAdmin + Admin) erişebilir (jurisdiction_list ile tutarlı)
-- ================================================================

DROP FUNCTION IF EXISTS catalog.jurisdiction_lookup();
DROP FUNCTION IF EXISTS catalog.jurisdiction_lookup(BIGINT);

CREATE OR REPLACE FUNCTION catalog.jurisdiction_lookup(
    p_caller_id BIGINT
)
RETURNS TABLE(
    id INT,
    code VARCHAR(20),
    name VARCHAR(100),
    country_code CHAR(2),
    authority_type VARCHAR(30),
    is_active BOOLEAN
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    -- Platform Admin check
    PERFORM security.user_assert_platform_admin(p_caller_id);

    RETURN QUERY
    SELECT
        j.id,
        j.code,
        j.name,
        j.country_code,
        j.authority_type,
        j.is_active
    FROM catalog.jurisdictions j
    ORDER BY j.name;
END;
$$;

COMMENT ON FUNCTION catalog.jurisdiction_lookup(BIGINT) IS 'Returns jurisdiction list for dropdowns. Platform Admin (SuperAdmin + Admin) only.';

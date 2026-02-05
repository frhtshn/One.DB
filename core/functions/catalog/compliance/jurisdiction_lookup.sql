-- ================================================================
-- JURISDICTION_LOOKUP: Jurisdiction dropdown için basit liste
-- ================================================================

DROP FUNCTION IF EXISTS catalog.jurisdiction_lookup();

CREATE OR REPLACE FUNCTION catalog.jurisdiction_lookup()
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

COMMENT ON FUNCTION catalog.jurisdiction_lookup IS 'Returns jurisdiction list for dropdowns.';

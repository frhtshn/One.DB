-- ================================================================
-- DATA_RETENTION_POLICY_LOOKUP: Dropdown için hafif listeleme
-- Jurisdiction ve kategori bilgileriyle özet görünüm
-- ================================================================

DROP FUNCTION IF EXISTS catalog.data_retention_policy_lookup(INT);

CREATE OR REPLACE FUNCTION catalog.data_retention_policy_lookup(
    p_jurisdiction_id INT DEFAULT NULL
)
RETURNS TABLE(
    id INT,
    jurisdiction_code VARCHAR(20),
    jurisdiction_name VARCHAR(100),
    data_category VARCHAR(50),
    retention_days INT,
    is_active BOOLEAN
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        drp.id,
        j.code AS jurisdiction_code,
        j.name AS jurisdiction_name,
        drp.data_category,
        drp.retention_days,
        drp.is_active
    FROM catalog.data_retention_policies drp
    JOIN catalog.jurisdictions j ON j.id = drp.jurisdiction_id
    WHERE (p_jurisdiction_id IS NULL OR drp.jurisdiction_id = p_jurisdiction_id)
    ORDER BY j.name, drp.data_category;
END;
$$;

COMMENT ON FUNCTION catalog.data_retention_policy_lookup IS 'Returns data retention policies for dropdowns. Lightweight version with jurisdiction info.';

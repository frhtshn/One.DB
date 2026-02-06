-- ================================================================
-- DATA_RETENTION_POLICY_GET: Tek bir veri saklama kuralını getirir
-- ID ile sorgulama, jurisdiction bilgileri dahil
-- ================================================================

DROP FUNCTION IF EXISTS catalog.data_retention_policy_get(INT);

CREATE OR REPLACE FUNCTION catalog.data_retention_policy_get(
    p_id INT
)
RETURNS TABLE(
    id INT,
    jurisdiction_id INT,
    jurisdiction_code VARCHAR(20),
    jurisdiction_name VARCHAR(100),
    data_category VARCHAR(50),
    retention_days INT,
    legal_reference VARCHAR(100),
    description VARCHAR(255),
    is_active BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
AS $$
BEGIN
    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.data-retention-policy.id-required';
    END IF;

    RETURN QUERY
    SELECT
        drp.id,
        drp.jurisdiction_id,
        j.code AS jurisdiction_code,
        j.name AS jurisdiction_name,
        drp.data_category,
        drp.retention_days,
        drp.legal_reference,
        drp.description,
        drp.is_active,
        drp.created_at,
        drp.updated_at
    FROM catalog.data_retention_policies drp
    JOIN catalog.jurisdictions j ON j.id = drp.jurisdiction_id
    WHERE drp.id = p_id;

    -- Bulunamadı kontrolü
    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.data-retention-policy.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION catalog.data_retention_policy_get IS 'Gets a single data retention policy by ID with jurisdiction info.';

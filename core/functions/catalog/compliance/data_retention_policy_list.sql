-- ================================================================
-- DATA_RETENTION_POLICY_LIST: Veri saklama kurallarını listeler
-- Jurisdiction bilgileriyle zenginleştirilmiş filtrelenebilir liste
-- Opsiyonel filtreler: jurisdiction, kategori, aktiflik
-- ================================================================

DROP FUNCTION IF EXISTS catalog.data_retention_policy_list(INT, VARCHAR, BOOLEAN);

CREATE OR REPLACE FUNCTION catalog.data_retention_policy_list(
    p_jurisdiction_id INT DEFAULT NULL,
    p_data_category VARCHAR(50) DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
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
    WHERE (p_jurisdiction_id IS NULL OR drp.jurisdiction_id = p_jurisdiction_id)
      AND (p_data_category IS NULL OR drp.data_category = p_data_category)
      AND (p_is_active IS NULL OR drp.is_active = p_is_active)
    ORDER BY j.name, drp.data_category;
END;
$$;

COMMENT ON FUNCTION catalog.data_retention_policy_list IS 'Lists data retention policies with jurisdiction info. Supports optional filtering by jurisdiction, category, and active status.';

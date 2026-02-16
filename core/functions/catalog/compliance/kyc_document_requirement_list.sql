-- ================================================================
-- KYC_DOCUMENT_REQUIREMENT_LIST: KYC belge gereksinimlerini listeler
-- Jurisdiction bazlı ve aktiflik durumuna göre filtreleme
-- ================================================================

DROP FUNCTION IF EXISTS catalog.kyc_document_requirement_list(INT);
DROP FUNCTION IF EXISTS catalog.kyc_document_requirement_list(INT, BOOLEAN);

CREATE OR REPLACE FUNCTION catalog.kyc_document_requirement_list(
    p_jurisdiction_id INT DEFAULT NULL,
    p_is_active BOOLEAN DEFAULT NULL
)
RETURNS TABLE(
    id INT,
    jurisdiction_id INT,
    jurisdiction_code VARCHAR(20),
    jurisdiction_name VARCHAR(100),
    document_type VARCHAR(30),
    accepted_subtypes JSONB,
    is_required BOOLEAN,
    required_for VARCHAR(30),
    max_document_age_days INT,
    expires_after_days INT,
    verification_method VARCHAR(30),
    display_order INT,
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
        kdr.id,
        kdr.jurisdiction_id,
        j.code AS jurisdiction_code,
        j.name AS jurisdiction_name,
        kdr.document_type,
        kdr.accepted_subtypes,
        kdr.is_required,
        kdr.required_for,
        kdr.max_document_age_days,
        kdr.expires_after_days,
        kdr.verification_method,
        kdr.display_order,
        kdr.is_active,
        kdr.created_at,
        kdr.updated_at
    FROM catalog.kyc_document_requirements kdr
    JOIN catalog.jurisdictions j ON j.id = kdr.jurisdiction_id
    WHERE (p_jurisdiction_id IS NULL OR kdr.jurisdiction_id = p_jurisdiction_id)
      AND (p_is_active IS NULL OR kdr.is_active = p_is_active)
    ORDER BY j.name, kdr.display_order, kdr.document_type;
END;
$$;

COMMENT ON FUNCTION catalog.kyc_document_requirement_list IS 'Lists KYC document requirements. Optional jurisdiction and is_active filters.';

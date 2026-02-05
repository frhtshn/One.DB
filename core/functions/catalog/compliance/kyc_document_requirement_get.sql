-- ================================================================
-- KYC_DOCUMENT_REQUIREMENT_GET: Tekil belge gereksinimi getirir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.kyc_document_requirement_get(INT);

CREATE OR REPLACE FUNCTION catalog.kyc_document_requirement_get(
    p_id INT
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
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-document-requirement.id-required';
    END IF;

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
        kdr.created_at,
        kdr.updated_at
    FROM catalog.kyc_document_requirements kdr
    JOIN catalog.jurisdictions j ON j.id = kdr.jurisdiction_id
    WHERE kdr.id = p_id;

    -- Bulunamadı kontrolü
    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-document-requirement.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION catalog.kyc_document_requirement_get IS 'Gets a single KYC document requirement by ID.';

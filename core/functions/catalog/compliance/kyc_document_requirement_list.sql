-- ================================================================
-- KYC_DOCUMENT_REQUIREMENT_LIST: KYC belge gereksinimlerini listeler
-- Platform Admin (SuperAdmin + Admin) erişebilir
-- Jurisdiction bazlı filtreleme
-- ================================================================

DROP FUNCTION IF EXISTS catalog.kyc_document_requirement_list(BIGINT, INT);

CREATE OR REPLACE FUNCTION catalog.kyc_document_requirement_list(
    p_caller_id BIGINT,
    p_jurisdiction_id INT DEFAULT NULL
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
    -- Platform Admin kontrolü (SuperAdmin veya Admin)
    IF NOT EXISTS(
        SELECT 1 FROM security.user_roles ur
        JOIN security.roles r ON ur.role_id = r.id
        WHERE ur.user_id = p_caller_id
          AND ur.tenant_id IS NULL
          AND r.code IN ('superadmin', 'admin')
          AND r.status = 1
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0403', MESSAGE = 'error.access.unauthorized';
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
    WHERE (p_jurisdiction_id IS NULL OR kdr.jurisdiction_id = p_jurisdiction_id)
    ORDER BY j.name, kdr.display_order, kdr.document_type;
END;
$$;

COMMENT ON FUNCTION catalog.kyc_document_requirement_list IS 'Lists KYC document requirements. Platform Admin only. Optional jurisdiction filter.';

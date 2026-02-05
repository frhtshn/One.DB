-- ================================================================
-- KYC_DOCUMENT_REQUIREMENT_CREATE: Yeni belge gereksinimi oluşturur
-- Aynı jurisdiction + document_type kombinasyonu kontrol edilir
-- ================================================================

DROP FUNCTION IF EXISTS catalog.kyc_document_requirement_create(
    INT, VARCHAR, JSONB, BOOLEAN, VARCHAR, INT, INT, VARCHAR, INT
);
DROP FUNCTION IF EXISTS catalog.kyc_document_requirement_create(
    INT, VARCHAR, TEXT, BOOLEAN, VARCHAR, INT, INT, VARCHAR, INT
);

CREATE OR REPLACE FUNCTION catalog.kyc_document_requirement_create(
    p_jurisdiction_id INT,
    p_document_type VARCHAR(30),
    p_accepted_subtypes TEXT DEFAULT NULL,
    p_is_required BOOLEAN DEFAULT TRUE,
    p_required_for VARCHAR(30) DEFAULT 'all',
    p_max_document_age_days INT DEFAULT NULL,
    p_expires_after_days INT DEFAULT NULL,
    p_verification_method VARCHAR(30) DEFAULT 'manual',
    p_display_order INT DEFAULT 0
)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_new_id INT;
BEGIN
    -- Jurisdiction kontrolü
    IF p_jurisdiction_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-document-requirement.jurisdiction-required';
    END IF;

    -- Jurisdiction varlık kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.jurisdictions j WHERE j.id = p_jurisdiction_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.jurisdiction.not-found';
    END IF;

    -- Document type kontrolü
    IF p_document_type IS NULL OR p_document_type NOT IN (
        'identity', 'proof_of_address', 'selfie', 'source_of_funds', 'bank_statement'
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-document-requirement.document-type-invalid';
    END IF;

    -- Required for kontrolü
    IF p_required_for IS NOT NULL AND p_required_for NOT IN ('all', 'deposit', 'withdrawal', 'edd') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-document-requirement.required-for-invalid';
    END IF;

    -- Verification method kontrolü
    IF p_verification_method IS NOT NULL AND p_verification_method NOT IN ('manual', 'automated', 'hybrid') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-document-requirement.verification-method-invalid';
    END IF;

    -- Duplicate kontrolü (aynı jurisdiction + document_type)
    IF EXISTS(
        SELECT 1 FROM catalog.kyc_document_requirements kdr
        WHERE kdr.jurisdiction_id = p_jurisdiction_id AND kdr.document_type = p_document_type
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.kyc-document-requirement.already-exists';
    END IF;

    -- Ekle
    INSERT INTO catalog.kyc_document_requirements (
        jurisdiction_id,
        document_type,
        accepted_subtypes,
        is_required,
        required_for,
        max_document_age_days,
        expires_after_days,
        verification_method,
        display_order,
        created_at,
        updated_at
    )
    VALUES (
        p_jurisdiction_id,
        p_document_type,
        p_accepted_subtypes::jsonb,
        COALESCE(p_is_required, TRUE),
        COALESCE(p_required_for, 'all'),
        p_max_document_age_days,
        p_expires_after_days,
        COALESCE(p_verification_method, 'manual'),
        COALESCE(p_display_order, 0),
        NOW(),
        NOW()
    )
    RETURNING catalog.kyc_document_requirements.id INTO v_new_id;

    RETURN v_new_id;
END;
$$;

COMMENT ON FUNCTION catalog.kyc_document_requirement_create IS 'Creates a KYC document requirement.';

-- ================================================================
-- KYC_DOCUMENT_REQUIREMENT_UPDATE: Belge gereksinimi günceller
-- NULL geçilen alanlar güncellenmez (COALESCE pattern)
-- ================================================================

DROP FUNCTION IF EXISTS catalog.kyc_document_requirement_update(
    INT, VARCHAR, TEXT, BOOLEAN, VARCHAR, INT, INT, VARCHAR, INT
);

CREATE OR REPLACE FUNCTION catalog.kyc_document_requirement_update(
    p_id INT,
    p_document_type VARCHAR(30) DEFAULT NULL,
    p_accepted_subtypes TEXT DEFAULT NULL,
    p_is_required BOOLEAN DEFAULT NULL,
    p_required_for VARCHAR(30) DEFAULT NULL,
    p_max_document_age_days INT DEFAULT NULL,
    p_expires_after_days INT DEFAULT NULL,
    p_verification_method VARCHAR(30) DEFAULT NULL,
    p_display_order INT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_jurisdiction_id INT;
    v_existing_id INT;
BEGIN
    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-document-requirement.id-required';
    END IF;

    -- Mevcut kayıt kontrolü ve jurisdiction_id al
    SELECT kdr.jurisdiction_id INTO v_jurisdiction_id
    FROM catalog.kyc_document_requirements kdr
    WHERE kdr.id = p_id;

    IF v_jurisdiction_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-document-requirement.not-found';
    END IF;

    -- Document type validasyonu
    IF p_document_type IS NOT NULL AND p_document_type NOT IN (
        'identity', 'proof_of_address', 'selfie', 'source_of_funds', 'bank_statement'
    ) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-document-requirement.document-type-invalid';
    END IF;

    -- Document type değişiyorsa duplicate kontrolü
    IF p_document_type IS NOT NULL THEN
        SELECT kdr.id INTO v_existing_id
        FROM catalog.kyc_document_requirements kdr
        WHERE kdr.jurisdiction_id = v_jurisdiction_id
          AND kdr.document_type = p_document_type
          AND kdr.id != p_id;

        IF v_existing_id IS NOT NULL THEN
            RAISE EXCEPTION USING ERRCODE = 'P0409', MESSAGE = 'error.kyc-document-requirement.already-exists';
        END IF;
    END IF;

    -- Required for validasyonu
    IF p_required_for IS NOT NULL AND p_required_for NOT IN ('all', 'deposit', 'withdrawal', 'edd') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-document-requirement.required-for-invalid';
    END IF;

    -- Verification method validasyonu
    IF p_verification_method IS NOT NULL AND p_verification_method NOT IN ('manual', 'automated', 'hybrid') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-document-requirement.verification-method-invalid';
    END IF;

    -- Güncelle
    UPDATE catalog.kyc_document_requirements SET
        document_type = COALESCE(p_document_type, document_type),
        accepted_subtypes = COALESCE(p_accepted_subtypes::jsonb, accepted_subtypes),
        is_required = COALESCE(p_is_required, is_required),
        required_for = COALESCE(p_required_for, required_for),
        max_document_age_days = COALESCE(p_max_document_age_days, max_document_age_days),
        expires_after_days = COALESCE(p_expires_after_days, expires_after_days),
        verification_method = COALESCE(p_verification_method, verification_method),
        display_order = COALESCE(p_display_order, display_order),
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.kyc_document_requirement_update IS 'Updates a KYC document requirement.';

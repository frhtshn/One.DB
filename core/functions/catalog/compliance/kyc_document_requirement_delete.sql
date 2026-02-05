-- ================================================================
-- KYC_DOCUMENT_REQUIREMENT_DELETE: Belge gereksinimi siler
-- ================================================================

DROP FUNCTION IF EXISTS catalog.kyc_document_requirement_delete(INT);

CREATE OR REPLACE FUNCTION catalog.kyc_document_requirement_delete(
    p_id INT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- ID kontrolü
    IF p_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-document-requirement.id-required';
    END IF;

    -- Mevcut kayıt kontrolü
    IF NOT EXISTS(SELECT 1 FROM catalog.kyc_document_requirements kdr WHERE kdr.id = p_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-document-requirement.not-found';
    END IF;

    -- Sil
    DELETE FROM catalog.kyc_document_requirements WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.kyc_document_requirement_delete IS 'Deletes a KYC document requirement.';

-- ================================================================
-- KYC_DOCUMENT_REQUIREMENT_DELETE: Belge gereksinimini pasife alır (soft delete)
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

    -- Soft delete
    UPDATE catalog.kyc_document_requirements SET
        is_active = FALSE,
        updated_at = NOW()
    WHERE id = p_id;
END;
$$;

COMMENT ON FUNCTION catalog.kyc_document_requirement_delete IS 'Soft-deletes a KYC document requirement by setting is_active to false.';

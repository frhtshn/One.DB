-- ================================================================
-- DOCUMENT_GET: Doküman detayı getir
-- ================================================================
-- Doküman bilgilerini döner (dosya verisi hariç).
-- file_data büyük olabilir, ayrı endpoint ile alınır.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.document_get(BIGINT);

CREATE OR REPLACE FUNCTION kyc.document_get(
    p_document_id BIGINT
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_document_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-document.document-required';
    END IF;

    SELECT jsonb_build_object(
        'id', d.id,
        'playerId', d.player_id,
        'kycCaseId', d.kyc_case_id,
        'documentType', d.document_type,
        'fileName', d.file_name,
        'mimeType', d.mime_type,
        'storageType', d.storage_type,
        'storagePath', d.storage_path,
        'fileSize', d.file_size,
        'status', d.status,
        'rejectionReason', d.rejection_reason,
        'uploadedAt', d.uploaded_at,
        'reviewedAt', d.reviewed_at,
        'expiresAt', d.expires_at,
        'createdAt', d.created_at
    )
    INTO v_result
    FROM kyc.player_documents d
    WHERE d.id = p_document_id;

    IF v_result IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-document.not-found';
    END IF;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION kyc.document_get IS 'Returns document metadata (excludes file_data for performance). File content fetched via separate endpoint.';

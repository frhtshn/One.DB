-- ================================================================
-- DOCUMENT_LIST: Doküman listesi
-- ================================================================
-- Oyuncunun dokümanlarını listeler.
-- Opsiyonel case, tip ve durum filtresi.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.document_list(BIGINT, BIGINT, VARCHAR, VARCHAR);

CREATE OR REPLACE FUNCTION kyc.document_list(
    p_player_id    BIGINT,
    p_kyc_case_id  BIGINT DEFAULT NULL,
    p_document_type VARCHAR(30) DEFAULT NULL,
    p_status       VARCHAR(30) DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-document.player-required';
    END IF;

    SELECT COALESCE(jsonb_agg(
        jsonb_build_object(
            'id', d.id,
            'kycCaseId', d.kyc_case_id,
            'documentType', d.document_type,
            'fileName', d.file_name,
            'mimeType', d.mime_type,
            'fileSize', d.file_size,
            'status', d.status,
            'rejectionReason', d.rejection_reason,
            'uploadedAt', d.uploaded_at,
            'reviewedAt', d.reviewed_at,
            'expiresAt', d.expires_at
        ) ORDER BY d.uploaded_at DESC
    ), '[]'::jsonb)
    INTO v_result
    FROM kyc.player_documents d
    WHERE d.player_id = p_player_id
      AND (p_kyc_case_id IS NULL OR d.kyc_case_id = p_kyc_case_id)
      AND (p_document_type IS NULL OR d.document_type = p_document_type)
      AND (p_status IS NULL OR d.status = p_status);

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION kyc.document_list IS 'Lists player documents with optional case, type and status filters.';

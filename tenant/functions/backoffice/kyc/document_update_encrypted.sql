-- ================================================================
-- DOCUMENT_UPDATE_ENCRYPTED: Sifreli dokuman verisi guncelleme
-- ================================================================
-- Re-encryption sonrasi file_data'yi gunceller.
-- Diger alanlara (status, metadata vb.) dokunmaz.
-- ================================================================

DROP FUNCTION IF EXISTS kyc.document_update_encrypted(BIGINT, BYTEA);

CREATE OR REPLACE FUNCTION kyc.document_update_encrypted(
    p_document_id BIGINT,
    p_file_data   BYTEA
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
BEGIN
    IF p_document_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-document.document-required';
    END IF;

    IF p_file_data IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-document.file-data-required';
    END IF;

    UPDATE kyc.player_documents
    SET file_data = p_file_data
    WHERE id = p_document_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-document.not-found';
    END IF;
END;
$$;

COMMENT ON FUNCTION kyc.document_update_encrypted IS 'Updates only file_data column after re-encryption. Does not modify status, metadata or other fields.';

-- ================================================================
-- DOCUMENT_UPLOAD: Doküman yükleme
-- ================================================================
-- Oyuncu dokümanını kaydeder (DB veya storage path).
-- Opsiyonel KYC case bağlantısı.
-- Workflow kaydı (case bağlıysa).
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.document_upload(BIGINT, BIGINT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, BYTEA, VARCHAR, VARCHAR, BYTEA, BIGINT);

CREATE OR REPLACE FUNCTION kyc.document_upload(
    p_player_id        BIGINT,
    p_kyc_case_id      BIGINT DEFAULT NULL,
    p_document_type    VARCHAR(30) DEFAULT NULL,
    p_file_name        VARCHAR(255) DEFAULT NULL,
    p_mime_type        VARCHAR(50) DEFAULT NULL,
    p_storage_type     VARCHAR(20) DEFAULT NULL,
    p_file_data        BYTEA DEFAULT NULL,
    p_storage_path     VARCHAR(500) DEFAULT NULL,
    p_encryption_key_id VARCHAR(100) DEFAULT NULL,
    p_file_hash        BYTEA DEFAULT NULL,
    p_file_size        BIGINT DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_doc_id BIGINT;
BEGIN
    IF p_player_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-document.player-required';
    END IF;

    IF p_document_type IS NULL OR TRIM(p_document_type) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-document.type-required';
    END IF;

    IF p_storage_type IS NULL OR TRIM(p_storage_type) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-document.storage-type-required';
    END IF;

    IF p_file_hash IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-document.hash-required';
    END IF;

    -- Oyuncu kontrolü
    IF NOT EXISTS (SELECT 1 FROM auth.players WHERE id = p_player_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-document.player-not-found';
    END IF;

    -- KYC case kontrolü (opsiyonel)
    IF p_kyc_case_id IS NOT NULL THEN
        IF NOT EXISTS (SELECT 1 FROM kyc.player_kyc_cases WHERE id = p_kyc_case_id AND player_id = p_player_id) THEN
            RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-document.case-not-found';
        END IF;
    END IF;

    -- Doküman kaydet
    INSERT INTO kyc.player_documents (
        player_id, kyc_case_id, document_type, file_name, mime_type,
        storage_type, file_data, storage_path, encryption_key_id,
        file_hash, file_size, status
    ) VALUES (
        p_player_id, p_kyc_case_id, p_document_type, p_file_name, p_mime_type,
        p_storage_type, p_file_data, p_storage_path, p_encryption_key_id,
        p_file_hash, COALESCE(p_file_size, 0), 'uploaded'
    )
    RETURNING id INTO v_doc_id;

    -- Selfie ise case'e bağla
    IF p_document_type = 'selfie' AND p_kyc_case_id IS NOT NULL THEN
        UPDATE kyc.player_kyc_cases
        SET selfie_document_id = v_doc_id,
            updated_at = NOW()
        WHERE id = p_kyc_case_id;
    END IF;

    -- KYC case bağlıysa workflow kaydı
    IF p_kyc_case_id IS NOT NULL THEN
        INSERT INTO kyc.player_kyc_workflows (
            kyc_case_id, current_status, action, reason
        )
        SELECT current_status, current_status, 'DOCUMENT_UPLOADED',
               'Document uploaded: ' || p_document_type
        FROM kyc.player_kyc_cases
        WHERE id = p_kyc_case_id;
    END IF;

    RETURN v_doc_id;
END;
$$;

COMMENT ON FUNCTION kyc.document_upload IS 'Uploads a player document (DB or storage path). Optional KYC case association with workflow entry.';

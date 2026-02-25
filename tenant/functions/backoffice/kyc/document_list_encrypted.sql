-- ================================================================
-- DOCUMENT_LIST_ENCRYPTED: Sifreli dokuman verilerini listele
-- ================================================================
-- Re-encryption icin file_data dahil doner.
-- Sadece storage_type='db' ve file_data IS NOT NULL kayitlar.
-- Mevcut document_list/document_get file_data'yi haric tutuyor
-- (performans) — bu fonksiyon re-encryption batch icin ozel.
-- ================================================================

DROP FUNCTION IF EXISTS kyc.document_list_encrypted(BIGINT);

CREATE OR REPLACE FUNCTION kyc.document_list_encrypted(
    p_player_id BIGINT
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
            'fileData', encode(d.file_data, 'base64')
        ) ORDER BY d.id
    ), '[]'::jsonb)
    INTO v_result
    FROM kyc.player_documents d
    WHERE d.player_id = p_player_id
      AND d.storage_type = 'db'
      AND d.file_data IS NOT NULL;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION kyc.document_list_encrypted IS 'Returns document IDs with encrypted file_data (base64) for re-encryption. Only DB-stored documents with non-null file_data.';

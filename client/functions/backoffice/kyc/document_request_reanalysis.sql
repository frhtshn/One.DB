-- ================================================================
-- DOCUMENT_REQUEST_REANALYSIS: Tekrar analiz talebi
-- ================================================================
-- Operatör tekrar analiz istediğinde belge durumunu 'analyzing'
-- yapar. Backend bu fonksiyon sonrası belge tipine göre uygun
-- IDManager endpoint'ini çağırır.
-- ================================================================

DROP FUNCTION IF EXISTS kyc.document_request_reanalysis(BIGINT, BIGINT);

CREATE OR REPLACE FUNCTION kyc.document_request_reanalysis(
    p_document_id  BIGINT,
    p_requested_by BIGINT
)
RETURNS VOID
LANGUAGE plpgsql
AS $$
DECLARE
    v_doc RECORD;
BEGIN
    IF p_document_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-document.document-required';
    END IF;

    -- Belge kontrolü
    SELECT d.id, d.kyc_case_id, d.status, d.document_type, d.player_id
    INTO v_doc
    FROM kyc.player_documents d
    WHERE d.id = p_document_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-document.not-found';
    END IF;

    -- Case bağlantısı zorunlu
    IF v_doc.kyc_case_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-reanalysis.case-required';
    END IF;

    -- Tekrar analize uygunluk kontrolü (sadece pending_review, approved veya rejected durumundaki belgeler)
    IF v_doc.status NOT IN ('pending_review', 'approved', 'rejected') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-reanalysis.not-eligible';
    END IF;

    -- Belge durumunu güncelle
    UPDATE kyc.player_documents
    SET status = 'analyzing'
    WHERE id = p_document_id;

    -- Workflow kaydı
    INSERT INTO kyc.player_kyc_workflows (
        kyc_case_id, current_status, action, performed_by, reason
    )
    SELECT current_status, current_status, 'REANALYSIS_REQUESTED', p_requested_by,
           'Reanalysis requested for ' || v_doc.document_type
    FROM kyc.player_kyc_cases
    WHERE id = v_doc.kyc_case_id;
END;
$$;

COMMENT ON FUNCTION kyc.document_request_reanalysis IS 'Requests reanalysis for a document. Sets status to analyzing. Backend calls appropriate IDManager endpoint after this.';

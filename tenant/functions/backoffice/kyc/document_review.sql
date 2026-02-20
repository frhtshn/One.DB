-- ================================================================
-- DOCUMENT_REVIEW: Doküman inceleme sonucu
-- ================================================================
-- Dokümanı onaylar veya reddeder.
-- KYC case bağlıysa workflow kaydı oluşturur.
-- Auth-agnostic (backend çağırır).
-- ================================================================

DROP FUNCTION IF EXISTS kyc.document_review(BIGINT, VARCHAR, VARCHAR, BIGINT);

CREATE OR REPLACE FUNCTION kyc.document_review(
    p_document_id      BIGINT,
    p_new_status       VARCHAR(30),
    p_rejection_reason VARCHAR(255) DEFAULT NULL,
    p_reviewed_by      BIGINT DEFAULT NULL
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

    IF p_new_status IS NULL OR TRIM(p_new_status) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-document.status-required';
    END IF;

    -- Doküman kontrolü
    SELECT d.id, d.kyc_case_id, d.status, d.document_type
    INTO v_doc
    FROM kyc.player_documents d
    WHERE d.id = p_document_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-document.not-found';
    END IF;

    -- Doküman güncelle
    UPDATE kyc.player_documents
    SET status = p_new_status,
        rejection_reason = p_rejection_reason,
        reviewed_at = NOW()
    WHERE id = p_document_id;

    -- KYC case bağlıysa workflow kaydı
    IF v_doc.kyc_case_id IS NOT NULL THEN
        INSERT INTO kyc.player_kyc_workflows (
            kyc_case_id, current_status, action, performed_by, reason
        )
        SELECT current_status, current_status, 'DOCUMENT_REVIEW', p_reviewed_by,
               v_doc.document_type || ' → ' || p_new_status
        FROM kyc.player_kyc_cases
        WHERE id = v_doc.kyc_case_id;
    END IF;
END;
$$;

COMMENT ON FUNCTION kyc.document_review IS 'Reviews a document (approve/reject). Creates workflow entry if linked to a KYC case.';

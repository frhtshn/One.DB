-- ================================================================
-- DOCUMENT_DECISION_CREATE: Operatör kararını kaydet
-- ================================================================
-- Operatörün belge onay/red kararını kaydeder.
-- document_decisions tablosuna INSERT, player_documents günceller.
-- Workflow kaydı oluşturur.
-- ================================================================

DROP FUNCTION IF EXISTS kyc.document_decision_create(BIGINT, BIGINT, VARCHAR, VARCHAR, BIGINT);

CREATE OR REPLACE FUNCTION kyc.document_decision_create(
    p_document_id  BIGINT,
    p_analysis_id  BIGINT DEFAULT NULL,
    p_decision     VARCHAR(10) DEFAULT NULL,
    p_reason       VARCHAR(500) DEFAULT NULL,
    p_decided_by   BIGINT DEFAULT NULL
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_doc          RECORD;
    v_decision_id  BIGINT;
BEGIN
    IF p_document_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-document.document-required';
    END IF;

    IF p_decided_by IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-decision.decided-by-required';
    END IF;

    -- Karar geçerlilik kontrolü
    IF p_decision NOT IN ('approved', 'rejected') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-decision.invalid-decision';
    END IF;

    -- Belge kontrolü
    SELECT d.id, d.player_id, d.kyc_case_id, d.document_type
    INTO v_doc
    FROM kyc.player_documents d
    WHERE d.id = p_document_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-decision.document-not-found';
    END IF;

    -- Karar kaydı oluştur
    INSERT INTO kyc.document_decisions (
        player_id, kyc_case_id, document_id, analysis_id,
        decision, reason, decided_by
    ) VALUES (
        v_doc.player_id, v_doc.kyc_case_id, p_document_id, p_analysis_id,
        p_decision, p_reason, p_decided_by
    )
    RETURNING id INTO v_decision_id;

    -- Belge durumunu güncelle
    UPDATE kyc.player_documents
    SET status = p_decision,
        rejection_reason = CASE WHEN p_decision = 'rejected' THEN p_reason ELSE rejection_reason END,
        reviewed_at = NOW()
    WHERE id = p_document_id;

    -- Workflow kaydı (case bağlıysa)
    IF v_doc.kyc_case_id IS NOT NULL THEN
        INSERT INTO kyc.player_kyc_workflows (
            kyc_case_id, current_status, action, performed_by, reason
        )
        SELECT current_status, current_status,
               CASE WHEN p_decision = 'approved' THEN 'DOCUMENT_APPROVED' ELSE 'DOCUMENT_REJECTED' END,
               p_decided_by,
               v_doc.document_type || ' → ' || p_decision || COALESCE(': ' || p_reason, '')
        FROM kyc.player_kyc_cases
        WHERE id = v_doc.kyc_case_id;
    END IF;

    RETURN v_decision_id;
END;
$$;

COMMENT ON FUNCTION kyc.document_decision_create IS 'Creates an operator decision (approve/reject) for a KYC document. Updates document status and creates workflow entry.';

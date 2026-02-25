-- ================================================================
-- DOCUMENT_ANALYSIS_SAVE: IDManager analiz sonucunu kaydet
-- ================================================================
-- Her iki pipeline'ın (kimlik + adres) sonucunu aynı fonksiyonla
-- kaydeder. Pipeline'a özgü parametreler nullable.
-- Belge status → 'pending_review' olarak güncellenir.
-- Workflow kaydı oluşturulur.
-- ================================================================

DROP FUNCTION IF EXISTS kyc.document_analysis_save(BIGINT, BIGINT, BIGINT, VARCHAR, VARCHAR, VARCHAR, VARCHAR, SMALLINT, TEXT[], JSONB, INTEGER, UUID, BOOLEAN, BOOLEAN, BOOLEAN, NUMERIC, NUMERIC, JSONB, TIMESTAMP);

CREATE OR REPLACE FUNCTION kyc.document_analysis_save(
    p_player_id            BIGINT,
    p_kyc_case_id          BIGINT,
    p_document_id          BIGINT,
    p_request_id           VARCHAR(100),
    p_analysis_type        VARCHAR(20),
    p_idm_document_type    VARCHAR(20),
    p_ai_decision          VARCHAR(10),
    p_risk_score           SMALLINT DEFAULT NULL,
    p_rejection_reasons    TEXT[] DEFAULT NULL,
    p_quality_details      JSONB DEFAULT NULL,
    p_processing_time_ms   INTEGER DEFAULT NULL,
    p_job_id               UUID DEFAULT NULL,
    -- Kimlik pipeline parametreleri (adres belgesi için NULL gönderilir)
    p_face_detected_doc    BOOLEAN DEFAULT NULL,
    p_face_detected_selfie BOOLEAN DEFAULT NULL,
    p_document_check       BOOLEAN DEFAULT NULL,
    p_similarity_score     NUMERIC(5,4) DEFAULT NULL,
    p_liveness_score       NUMERIC(5,4) DEFAULT NULL,
    -- Adres pipeline parametreleri (kimlik belgesi için NULL gönderilir)
    p_address_doc_details  JSONB DEFAULT NULL,
    p_analyzed_at          TIMESTAMP DEFAULT NOW()
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
    v_analysis_id BIGINT;
BEGIN
    -- Zorunlu alan kontrolleri
    IF p_kyc_case_id IS NULL THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-analysis.case-required';
    END IF;

    IF p_request_id IS NULL OR TRIM(p_request_id) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-analysis.request-id-required';
    END IF;

    IF p_ai_decision IS NULL OR TRIM(p_ai_decision) = '' THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-analysis.decision-required';
    END IF;

    -- analysis_type geçerlilik kontrolü
    IF p_analysis_type NOT IN ('analyze', 'analyze_selfie', 'analyze_document') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-analysis.invalid-type';
    END IF;

    -- idm_document_type geçerlilik kontrolü
    IF p_idm_document_type NOT IN ('ID_CARD', 'UTILITY_BILL', 'BANK_STATEMENT', 'INVOICE', 'OTHER_DOCUMENT') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-analysis.invalid-document-type';
    END IF;

    -- ai_decision geçerlilik kontrolü
    IF p_ai_decision NOT IN ('PASS', 'REVIEW', 'REJECT') THEN
        RAISE EXCEPTION USING ERRCODE = 'P0400', MESSAGE = 'error.kyc-analysis.decision-required';
    END IF;

    -- Belge varlık kontrolü
    IF NOT EXISTS (SELECT 1 FROM kyc.player_documents WHERE id = p_document_id AND player_id = p_player_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-analysis.document-not-found';
    END IF;

    -- KYC case varlık ve player_id eşleşme kontrolü
    IF NOT EXISTS (SELECT 1 FROM kyc.player_kyc_cases WHERE id = p_kyc_case_id AND player_id = p_player_id) THEN
        RAISE EXCEPTION USING ERRCODE = 'P0404', MESSAGE = 'error.kyc-analysis.case-not-found';
    END IF;

    -- Analiz kaydı oluştur
    INSERT INTO kyc.document_analysis (
        player_id, kyc_case_id, document_id,
        request_id, job_id, analysis_type, idm_document_type,
        face_detected_doc, face_detected_selfie, document_check,
        similarity_score, liveness_score,
        address_doc_details,
        risk_score, ai_decision, rejection_reasons,
        quality_details, processing_time_ms,
        analyzed_at
    ) VALUES (
        p_player_id, p_kyc_case_id, p_document_id,
        p_request_id, p_job_id, p_analysis_type, p_idm_document_type,
        p_face_detected_doc, p_face_detected_selfie, p_document_check,
        p_similarity_score, p_liveness_score,
        p_address_doc_details,
        p_risk_score, p_ai_decision, p_rejection_reasons,
        p_quality_details, p_processing_time_ms,
        p_analyzed_at
    )
    RETURNING id INTO v_analysis_id;

    -- Belge durumunu güncelle
    UPDATE kyc.player_documents
    SET status = 'pending_review'
    WHERE id = p_document_id;

    -- Workflow kaydı
    INSERT INTO kyc.player_kyc_workflows (
        kyc_case_id, current_status, action, reason
    )
    SELECT current_status, current_status, 'ANALYSIS_COMPLETED',
           p_analysis_type || ' (' || p_idm_document_type || ') → ' || p_ai_decision
    FROM kyc.player_kyc_cases
    WHERE id = p_kyc_case_id;

    RETURN v_analysis_id;
END;
$$;

COMMENT ON FUNCTION kyc.document_analysis_save IS 'Saves IDManager AI analysis result for a KYC document. Supports both identity and address pipelines. Updates document status to pending_review.';

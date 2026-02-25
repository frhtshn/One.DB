-- ================================================================
-- DOCUMENT_REVIEW: Doküman inceleme sonucu [DEPRECATED]
-- ================================================================
-- DEPRECATED: Bu fonksiyon document_decision_create() lehine
-- kullanımdan kaldırılmıştır. Geçiş süreci için korunmaktadır.
-- Yeni kod document_decision_create() kullanmalıdır.
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
BEGIN
    -- DEPRECATED: document_decision_create() kullanın
    -- Geriye uyumluluk için document_decision_create()'e yönlendir
    IF p_new_status IN ('approved', 'rejected') THEN
        PERFORM kyc.document_decision_create(
            p_document_id  := p_document_id,
            p_analysis_id  := NULL,
            p_decision     := p_new_status,
            p_reason       := p_rejection_reason,
            p_decided_by   := COALESCE(p_reviewed_by, 0)
        );
    ELSE
        -- approved/rejected dışı durumlar için eski mantığı koru
        UPDATE kyc.player_documents
        SET status = p_new_status,
            rejection_reason = p_rejection_reason,
            reviewed_at = NOW()
        WHERE id = p_document_id;
    END IF;
END;
$$;

COMMENT ON FUNCTION kyc.document_review IS 'DEPRECATED: Use document_decision_create() instead. Kept for backward compatibility during transition.';

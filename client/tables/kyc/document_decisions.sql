-- =============================================
-- Document Decisions (Operatör Karar Geçmişi)
-- Her operatör kararı yeni satır oluşturur
-- Son kayıt = geçerli karar. Append-only.
-- =============================================

DROP TABLE IF EXISTS kyc.document_decisions CASCADE;

CREATE TABLE kyc.document_decisions (
    id BIGSERIAL PRIMARY KEY,

    player_id BIGINT NOT NULL,                    -- Oyuncu ID
    kyc_case_id BIGINT NOT NULL,                  -- Bağlı KYC vakası
    document_id BIGINT NOT NULL,                  -- Karar verilen belge → player_documents.id
    analysis_id BIGINT,                           -- Hangi analiz sonucuna bakılarak karar verildi (nullable)

    decision VARCHAR(10) NOT NULL,                -- Operatör kararı
    -- approved: Onaylandı
    -- rejected: Reddedildi

    reason VARCHAR(500),                          -- Operatör notu / açıklaması

    decided_by BIGINT NOT NULL,                   -- Kararı veren BO kullanıcı ID
    decided_at TIMESTAMP NOT NULL DEFAULT now(),  -- Karar zamanı
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

COMMENT ON TABLE kyc.document_decisions IS 'Operator decision history for KYC documents. Append-only: latest row per document is the current decision.';

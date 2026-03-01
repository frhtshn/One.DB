-- =============================================
-- Document Analysis (IDManager Analiz Sonuçları)
-- Her iki pipeline (kimlik + adres) sonuçları
-- Append-only: her analiz yeni satır oluşturur
-- =============================================

DROP TABLE IF EXISTS kyc.document_analysis CASCADE;

CREATE TABLE kyc.document_analysis (
    id BIGSERIAL PRIMARY KEY,

    player_id BIGINT NOT NULL,                    -- Oyuncu ID
    kyc_case_id BIGINT NOT NULL,                  -- Bağlı KYC vakası (zorunlu)
    document_id BIGINT NOT NULL,                  -- Analiz edilen belge → player_documents.id

    -- IDManager İstek Bilgileri
    request_id VARCHAR(100) NOT NULL,             -- IDManager request_id (tracing)
    job_id UUID,                                  -- Async mod için job UUID (nullable)
    analysis_type VARCHAR(20) NOT NULL,           -- Analiz tipi
    -- analyze: Tam analiz (kimlik + selfie karşılaştırma)
    -- analyze_selfie: Sadece selfie (canlılık + kalite)
    -- analyze_document: Belge doğrulama (kimlik veya adres)

    idm_document_type VARCHAR(20) NOT NULL,       -- IDManager DocumentType enum değeri
    -- ID_CARD: Kimlik kartı, pasaport, ehliyet (kimlik pipeline)
    -- UTILITY_BILL: Fatura (adres pipeline)
    -- BANK_STATEMENT: Banka hesap özeti (adres pipeline)
    -- INVOICE: Fatura (adres pipeline)
    -- OTHER_DOCUMENT: Diğer (adres pipeline)

    -- ============================================
    -- Kimlik Pipeline Sonuçları (adres belgesi için NULL)
    -- ============================================
    face_detected_doc BOOLEAN,                    -- Belgede yüz bulundu mu
    face_detected_selfie BOOLEAN,                 -- Selfie'de yüz bulundu mu
    document_check BOOLEAN,                       -- Belge formatı geçerli mi (heuristic)
    similarity_score NUMERIC(5,4),                -- Yüz benzerliği (0.0000-1.0000)
    liveness_score NUMERIC(5,4),                  -- Canlılık skoru (0.0000-1.0000)

    -- ============================================
    -- Adres Pipeline Sonuçları (kimlik belgesi için NULL)
    -- ============================================
    address_doc_details JSONB,                    -- Adres belgesi analiz detayları
    -- Örnek: {
    --   "text_density": 0.15,
    --   "table_detected": true,
    --   "date_found": true,
    --   "page_count": 3,
    --   "is_valid": true
    -- }

    -- ============================================
    -- Ortak Alanlar (her iki pipeline)
    -- ============================================
    risk_score SMALLINT,                          -- Toplam risk skoru
    -- Kimlik: 0-100 (similarity + liveness + quality)
    -- Adres: 0-110 (valid_doc + text_density + table + date + quality)

    ai_decision VARCHAR(10) NOT NULL,             -- IDManager kararı
    -- PASS: Skor ≥70
    -- REVIEW: Skor 40-69
    -- REJECT: Skor <40 veya hard reject

    rejection_reasons TEXT[],                     -- IDManager red sebepleri
    -- Kimlik: no_face_in_id, no_face_in_selfie, not_a_document,
    --         low_quality, low_resolution, face_too_small,
    --         excessive_yaw, excessive_pitch
    -- Adres:  invalid_document, low_text_density, no_table_structure,
    --         no_date_pattern, page_count_exceeded

    quality_details JSONB,                        -- Kalite detayları (her iki pipeline)
    -- Kimlik örnek: {
    --   "id_blur_score": 250.5, "selfie_blur_score": 310.2,
    --   "id_face_size": 0.152, "selfie_face_size": 0.320,
    --   "selfie_face_angle": {"yaw": 2.1, "pitch": -1.5}
    -- }
    -- Adres örnek: {
    --   "page_count": 3, "is_pdf": true, "dpi": 150
    -- }

    processing_time_ms INTEGER,                   -- IDManager işlem süresi (ms)

    -- Meta
    analyzed_at TIMESTAMP NOT NULL DEFAULT now(), -- Analiz zamanı
    created_at TIMESTAMP NOT NULL DEFAULT now()
);

COMMENT ON TABLE kyc.document_analysis IS 'IDManager AI analysis results for KYC documents. Supports both identity (face) and address (document) pipelines. Append-only.';

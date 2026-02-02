-- =============================================
-- Player KYC Workflows (KYC İş Akışı Geçmişi)
-- KYC vakası üzerindeki tüm işlemler
-- Durum değişiklikleri, onay/red geçmişi
-- =============================================

DROP TABLE IF EXISTS kyc.player_kyc_workflows CASCADE;

CREATE TABLE kyc.player_kyc_workflows (
    id BIGSERIAL PRIMARY KEY,

    kyc_case_id BIGINT NOT NULL,                  -- Bağlı KYC vakası ID

    previous_status VARCHAR(30),                  -- Önceki durum
    current_status VARCHAR(30) NOT NULL,          -- Yeni durum

    action VARCHAR(50),                           -- Yapılan işlem
    -- document_uploaded: Belge yüklendi
    -- review_started: İnceleme başladı
    -- approved: Onaylandı
    -- rejected: Reddedildi
    -- expired: Süresi doldu

    performed_by BIGINT,                          -- İşlemi yapan (inceleyici veya sistem)

    reason VARCHAR(255),                          -- İşlem açıklaması

    created_at TIMESTAMP NOT NULL DEFAULT now()
);

COMMENT ON TABLE kyc.player_kyc_workflows IS 'KYC workflow history tracking all status changes, approvals, and rejections for audit purposes';


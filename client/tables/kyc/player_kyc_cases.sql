-- =============================================
-- Player KYC Cases (Oyuncu KYC Vakası)
-- Her oyuncunun kimlik doğrulama süreci
-- Durum, seviye ve risk değerlendirmesi
-- =============================================

DROP TABLE IF EXISTS kyc.player_kyc_cases CASCADE;

CREATE TABLE kyc.player_kyc_cases (
    id BIGSERIAL PRIMARY KEY,

    player_id BIGINT NOT NULL,                    -- Oyuncu ID

    current_status VARCHAR(30) NOT NULL,          -- Mevcut durum
    -- not_started: Başlamadı
    -- in_review: İncelemede
    -- approved: Onaylandı
    -- rejected: Reddedildi
    -- suspended: Askıya alındı

    kyc_level VARCHAR(20),                        -- KYC seviyesi
    -- basic: Temel doğrulama
    -- standard: Standart doğrulama
    -- enhanced: Gelişmiş doğrulama (yüksek limitler için)

    risk_level VARCHAR(20),                       -- Risk seviyesi
    -- low: Düşük risk
    -- medium: Orta risk
    -- high: Yüksek risk

    assigned_reviewer_id BIGINT,                  -- Atanan inceleyici (BO kullanıcısı)

    last_decision_reason VARCHAR(255),            -- Son karar açıklaması

    selfie_document_id BIGINT,                    -- Case'e ait selfie → player_documents.id

    created_at TIMESTAMP NOT NULL DEFAULT now(),
    updated_at TIMESTAMP NOT NULL DEFAULT now()
);

COMMENT ON TABLE kyc.player_kyc_cases IS 'Player KYC verification cases tracking status, level, and risk assessment through the verification process';


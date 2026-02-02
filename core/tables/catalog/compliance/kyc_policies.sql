-- =============================================
-- KYC Policies (KYC Politikaları)
-- Jurisdiction bazlı KYC kuralları
-- Doğrulama zamanlaması ve eşikler
-- =============================================

DROP TABLE IF EXISTS catalog.kyc_policies CASCADE;

CREATE TABLE catalog.kyc_policies (
    id serial PRIMARY KEY,

    jurisdiction_id int NOT NULL UNIQUE,           -- Hangi otorite için (1:1)

    -- Doğrulama zamanlaması
    verification_timing varchar(30) NOT NULL,     -- Ne zaman doğrulama yapılmalı
    -- before_registration: Kayıt öncesi (UK, Almanya)
    -- before_deposit: Para yatırmadan önce
    -- after_registration: Kayıttan sonra (Malta - 72 saat)
    -- before_withdrawal: Para çekmeden önce

    -- Doğrulama süreleri (saat)
    verification_deadline_hours int,              -- Doğrulama tamamlanma süresi (NULL = hemen)
    grace_period_hours int DEFAULT 0,             -- Ücretsiz oyun için tanınan süre

    -- Enhanced Due Diligence (EDD) eşikleri
    edd_deposit_threshold decimal(18,2),          -- EDD gereken para yatırma eşiği
    edd_withdrawal_threshold decimal(18,2),       -- EDD gereken para çekme eşiği
    edd_cumulative_threshold decimal(18,2),       -- Kümülatif işlem eşiği
    edd_threshold_currency character(3) DEFAULT 'EUR', -- Eşik para birimi

    -- Yaş doğrulama
    min_age int NOT NULL DEFAULT 18,              -- Minimum yaş
    age_verification_required boolean NOT NULL DEFAULT true,

    -- Adres doğrulama
    address_verification_required boolean NOT NULL DEFAULT true,
    address_document_max_age_days int DEFAULT 90, -- Adres belgesi max yaşı (gün)

    -- Kaynak doğrulama (Source of Funds)
    sof_threshold decimal(18,2),                  -- SOF gereken eşik
    sof_required_above_threshold boolean DEFAULT false,

    -- PEP ve Sanctions taraması
    pep_screening_required boolean NOT NULL DEFAULT true,
    sanctions_screening_required boolean NOT NULL DEFAULT true,

    -- Durum
    is_active boolean NOT NULL DEFAULT true,

    created_at timestamp NOT NULL DEFAULT now(),
    updated_at timestamp NOT NULL DEFAULT now()
);

COMMENT ON TABLE catalog.kyc_policies IS 'Jurisdiction-specific KYC verification policies and thresholds';

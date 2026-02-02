-- =============================================
-- KYC Level Requirements (KYC Seviye Gereksinimleri)
-- Jurisdiction bazlı KYC seviye geçiş kuralları
-- BASIC → STANDARD → ENHANCED geçiş eşikleri
-- =============================================

DROP TABLE IF EXISTS catalog.kyc_level_requirements CASCADE;

CREATE TABLE catalog.kyc_level_requirements (
    id serial PRIMARY KEY,

    jurisdiction_id int NOT NULL,                 -- Hangi otorite için

    -- KYC Seviyesi
    kyc_level varchar(20) NOT NULL,               -- Seviye
    -- basic: Temel doğrulama (email, telefon)
    -- standard: Standart doğrulama (kimlik, adres)
    -- enhanced: Gelişmiş doğrulama (SOF, EDD)

    -- Bu seviyeye geçiş için gerekli koşullar
    -- (herhangi biri tetikler - OR logic)
    trigger_cumulative_deposit decimal(18,2),     -- Toplam para yatırma eşiği
    trigger_cumulative_withdrawal decimal(18,2),  -- Toplam para çekme eşiği
    trigger_single_deposit decimal(18,2),         -- Tek seferde para yatırma eşiği
    trigger_single_withdrawal decimal(18,2),      -- Tek seferde para çekme eşiği
    trigger_balance_threshold decimal(18,2),      -- Bakiye eşiği
    trigger_threshold_currency character(3) DEFAULT 'EUR',

    -- Zamana bağlı tetikleyiciler
    trigger_days_since_registration int,          -- Kayıttan bu kadar gün sonra
    trigger_on_first_withdrawal boolean DEFAULT false, -- İlk çekimde tetikle

    -- Bu seviyede izin verilen işlemler
    max_single_deposit decimal(18,2),             -- Max tek seferde yatırma
    max_single_withdrawal decimal(18,2),          -- Max tek seferde çekme
    max_daily_deposit decimal(18,2),              -- Max günlük yatırma
    max_daily_withdrawal decimal(18,2),           -- Max günlük çekme
    max_monthly_deposit decimal(18,2),            -- Max aylık yatırma
    max_monthly_withdrawal decimal(18,2),         -- Max aylık çekme
    limit_currency character(3) DEFAULT 'EUR',

    -- Bu seviye için gerekli belgeler (JSON array)
    required_documents jsonb,                     -- ["IDENTITY", "PROOF_OF_ADDRESS", "SELFIE"]

    -- Bu seviye için gerekli doğrulamalar (JSON array)
    required_verifications jsonb,                 -- ["EMAIL", "PHONE", "PEP_CHECK", "SANCTIONS_CHECK"]

    -- Doğrulama süresi
    verification_deadline_hours int,              -- Bu seviyeyi tamamlama süresi
    grace_period_hours int DEFAULT 0,             -- Süre dolmadan izin verilen işlemler

    -- Süre dolduktan sonra ne yapılacak
    on_deadline_action varchar(30) DEFAULT 'block_deposits',
    -- block_deposits: Para yatırmayı engelle
    -- block_withdrawals: Para çekmeyi engelle
    -- block_all: Tüm işlemleri engelle
    -- suspend_account: Hesabı askıya al

    -- Sıralama (seviye hiyerarşisi)
    level_order int NOT NULL DEFAULT 0,           -- 0=BASIC, 1=STANDARD, 2=ENHANCED

    -- Durum
    is_active boolean NOT NULL DEFAULT true,

    created_at timestamp NOT NULL DEFAULT now(),
    updated_at timestamp NOT NULL DEFAULT now(),

    UNIQUE(jurisdiction_id, kyc_level)
);

COMMENT ON TABLE catalog.kyc_level_requirements IS 'KYC level transition rules and thresholds per jurisdiction. Defines when players must upgrade their verification level.';

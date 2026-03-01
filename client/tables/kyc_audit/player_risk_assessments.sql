-- =============================================
-- Player Risk Assessments (Risk Değerlendirmeleri)
-- Oyuncu risk skorlama ve değerlendirme geçmişi
-- AML/KYC risk bazlı yaklaşım için
-- CLIENT_AUDIT DB - 5-10 yıl retention
-- =============================================

DROP TABLE IF EXISTS kyc_audit.player_risk_assessments CASCADE;

CREATE TABLE kyc_audit.player_risk_assessments (
    id bigserial PRIMARY KEY,

    player_id bigint NOT NULL,                    -- Oyuncu ID (client DB referans)

    -- Değerlendirme tipi
    assessment_type varchar(30) NOT NULL,         -- Değerlendirme türü
    -- initial: Kayıt anında ilk değerlendirme
    -- periodic: Periyodik yeniden değerlendirme
    -- triggered: Olay bazlı (büyük işlem, şüpheli aktivite vb.)
    -- manual: Manuel admin değerlendirmesi

    -- Risk skoru
    risk_score int NOT NULL,                      -- Toplam risk skoru (0-100)
    risk_level varchar(20) NOT NULL,              -- Risk seviyesi
    -- low: Düşük risk (0-30)
    -- medium: Orta risk (31-60)
    -- high: Yüksek risk (61-85)
    -- critical: Kritik risk (86-100)

    previous_risk_level varchar(20),              -- Önceki risk seviyesi
    risk_change varchar(20),                      -- Değişim yönü
    -- increased: Arttı
    -- decreased: Azaldı
    -- unchanged: Değişmedi

    -- Risk faktörleri (JSON detay)
    risk_factors jsonb NOT NULL,                  -- Risk faktör detayları
    -- {
    --   "country_risk": { "score": 20, "country": "TR", "tier": "MEDIUM" },
    --   "occupation_risk": { "score": 10, "occupation": "...", "tier": "LOW" },
    --   "pep_status": { "score": 0, "is_pep": false },
    --   "transaction_pattern": { "score": 15, "flags": [...] },
    --   "source_of_funds": { "score": 5, "verified": true },
    --   "age_risk": { "score": 0, "age": 35 },
    --   "verification_status": { "score": 10, "level": "STANDARD" }
    -- }

    -- Bireysel risk skorları
    country_risk_score int DEFAULT 0,             -- Ülke riski
    occupation_risk_score int DEFAULT 0,          -- Meslek riski
    pep_risk_score int DEFAULT 0,                 -- PEP riski
    transaction_risk_score int DEFAULT 0,         -- İşlem pattern riski
    sof_risk_score int DEFAULT 0,                 -- Kaynak riski
    behavioral_risk_score int DEFAULT 0,          -- Davranışsal risk

    -- Tetikleyici olay (triggered tipi için)
    trigger_event varchar(50),                    -- Tetikleyen olay
    -- large_deposit: Büyük para yatırma
    -- large_withdrawal: Büyük para çekme
    -- unusual_pattern: Olağandışı işlem paterni
    -- screening_match: Tarama eşleşmesi
    -- jurisdiction_change: Ülke değişikliği
    -- document_expiry: Belge süresi dolması

    trigger_reference_id bigint,                  -- Tetikleyen kayıt ID (transaction, screening vb.)
    trigger_details jsonb,                        -- Tetikleyici detayları

    -- Önerilen aksiyonlar
    recommended_actions jsonb,                    -- Önerilen işlemler
    -- ["ENHANCED_MONITORING", "REQUEST_SOF", "MANUAL_REVIEW", "BLOCK_WITHDRAWALS"]

    -- Değerlendirmeyi yapan
    assessed_by varchar(20) NOT NULL DEFAULT 'system',
    -- system: Otomatik hesaplama
    -- admin: Manuel değerlendirme
    admin_user_id bigint,                         -- Admin ise kullanıcı ID

    -- Onay (yüksek risk için)
    requires_approval boolean DEFAULT false,      -- Onay gerekiyor mu?
    approved_by bigint,                           -- Onaylayan admin
    approved_at timestamp,                        -- Onay tarihi
    approval_notes text,                          -- Onay notları

    -- Geçerlilik
    valid_until timestamp,                        -- Değerlendirme geçerlilik tarihi
    superseded_by bigint,                         -- Yerine geçen değerlendirme ID

    created_at timestamp NOT NULL DEFAULT now()
);

COMMENT ON TABLE kyc_audit.player_risk_assessments IS 'Player risk scoring and assessment history for AML/KYC risk-based approach. Retention: 5-10 years.';

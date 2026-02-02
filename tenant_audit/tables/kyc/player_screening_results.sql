-- =============================================
-- Player Screening Results (Tarama Sonuçları)
-- PEP, Sanctions ve Adverse Media taramaları
-- Düzenleyici uyumluluk için zorunlu kontroller
-- TENANT_AUDIT DB - 5-10 yıl retention
-- =============================================

DROP TABLE IF EXISTS kyc_audit.player_screening_results CASCADE;

CREATE TABLE kyc_audit.player_screening_results (
    id bigserial PRIMARY KEY,

    player_id bigint NOT NULL,                    -- Oyuncu ID (tenant DB referans)
    kyc_case_id bigint,                           -- Bağlı KYC vakası (tenant DB referans)

    -- Tarama tipi
    screening_type varchar(30) NOT NULL,          -- Tarama türü
    -- PEP: Politically Exposed Person
    -- SANCTIONS: Yaptırım listesi kontrolü
    -- ADVERSE_MEDIA: Olumsuz medya taraması
    -- WATCHLIST: Genel izleme listesi
    -- FRAUD: Dolandırıcılık veritabanı

    -- Tarama sağlayıcısı
    provider_code varchar(50) NOT NULL,           -- Sağlayıcı kodu
    -- SUMSUB, ONFIDO, REFINITIV, DOW_JONES, COMPLY_ADVANTAGE, INTERNAL

    provider_reference varchar(100),              -- Sağlayıcı referans ID
    provider_scan_id varchar(100),                -- Tarama ID

    -- Tarama sonucu
    result_status varchar(30) NOT NULL,           -- Sonuç durumu
    -- CLEAR: Temiz - eşleşme yok
    -- POTENTIAL_MATCH: Potansiyel eşleşme - inceleme gerekli
    -- CONFIRMED_MATCH: Doğrulanmış eşleşme
    -- FALSE_POSITIVE: Yanlış pozitif (inceleme sonrası)
    -- ERROR: Tarama hatası

    -- Eşleşme detayları
    match_score int,                              -- Eşleşme skoru (0-100)
    match_count int DEFAULT 0,                    -- Bulunan eşleşme sayısı

    -- Eşleşme verileri (JSON)
    matched_entities jsonb,                       -- Eşleşen kayıtlar
    -- [{ "name": "...", "list": "...", "score": 95, "details": {...} }]

    -- Ham sağlayıcı yanıtı
    raw_response jsonb,                           -- Sağlayıcı raw response

    -- İnceleme durumu
    review_status varchar(20) NOT NULL DEFAULT 'PENDING',
    -- PENDING: İnceleme bekliyor
    -- REVIEWED: İncelendi
    -- ESCALATED: Üst seviyeye iletildi

    reviewed_by bigint,                           -- İnceleyen admin ID
    reviewed_at timestamp,                        -- İnceleme tarihi
    review_decision varchar(30),                  -- İnceleme kararı
    -- CLEARED: Temiz kabul edildi
    -- BLOCKED: Hesap engellendi
    -- MONITORING: İzlemeye alındı
    review_notes text,                            -- İnceleme notları

    -- Tarihler
    screened_at timestamp NOT NULL DEFAULT now(), -- Tarama tarihi
    expires_at timestamp,                         -- Sonuç geçerlilik tarihi
    next_screening_due timestamp,                 -- Sonraki tarama zamanı

    created_at timestamp NOT NULL DEFAULT now()
);

COMMENT ON TABLE kyc_audit.player_screening_results IS 'PEP, Sanctions, and Adverse Media screening results for regulatory compliance. Retention: 5-10 years.';

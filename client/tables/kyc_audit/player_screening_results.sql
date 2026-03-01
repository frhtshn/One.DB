-- =============================================
-- Player Screening Results (Tarama Sonuçları)
-- PEP, Sanctions ve Adverse Media taramaları
-- Düzenleyici uyumluluk için zorunlu kontroller
-- CLIENT_AUDIT DB - 5-10 yıl retention
-- =============================================

DROP TABLE IF EXISTS kyc_audit.player_screening_results CASCADE;

CREATE TABLE kyc_audit.player_screening_results (
    id bigserial PRIMARY KEY,

    player_id bigint NOT NULL,                    -- Oyuncu ID (client DB referans)
    kyc_case_id bigint,                           -- Bağlı KYC vakası (client DB referans)

    -- Tarama tipi
    screening_type varchar(30) NOT NULL,          -- Tarama türü
    -- pep: Politically Exposed Person
    -- sanctions: Yaptırım listesi kontrolü
    -- adverse_media: Olumsuz medya taraması
    -- watchlist: Genel izleme listesi
    -- fraud: Dolandırıcılık veritabanı

    -- Tarama sağlayıcısı
    provider_code varchar(50) NOT NULL,           -- Sağlayıcı kodu
    -- SUMSUB, ONFIDO, REFINITIV, DOW_JONES, COMPLY_ADVANTAGE, INTERNAL

    provider_reference varchar(100),              -- Sağlayıcı referans ID
    provider_scan_id varchar(100),                -- Tarama ID

    -- Tarama sonucu
    result_status varchar(30) NOT NULL,           -- Sonuç durumu
    -- clear: Temiz - eşleşme yok
    -- potential_match: Potansiyel eşleşme - inceleme gerekli
    -- confirmed_match: Doğrulanmış eşleşme
    -- false_positive: Yanlış pozitif (inceleme sonrası)
    -- error: Tarama hatası

    -- Eşleşme detayları
    match_score int,                              -- Eşleşme skoru (0-100)
    match_count int DEFAULT 0,                    -- Bulunan eşleşme sayısı

    -- Eşleşme verileri (JSON)
    matched_entities jsonb,                       -- Eşleşen kayıtlar
    -- [{ "name": "...", "list": "...", "score": 95, "details": {...} }]

    -- Ham sağlayıcı yanıtı
    raw_response jsonb,                           -- Sağlayıcı raw response

    -- İnceleme durumu
    review_status varchar(20) NOT NULL DEFAULT 'pending',
    -- pending: İnceleme bekliyor
    -- reviewed: İncelendi
    -- escalated: Üst seviyeye iletildi

    reviewed_by bigint,                           -- İnceleyen admin ID
    reviewed_at timestamp,                        -- İnceleme tarihi
    review_decision varchar(30),                  -- İnceleme kararı
    -- cleared: Temiz kabul edildi
    -- blocked: Hesap engellendi
    -- monitoring: İzlemeye alındı
    review_notes text,                            -- İnceleme notları

    -- Tarihler
    screened_at timestamp NOT NULL DEFAULT now(), -- Tarama tarihi
    expires_at timestamp,                         -- Sonuç geçerlilik tarihi
    next_screening_due timestamp,                 -- Sonraki tarama zamanı

    created_at timestamp NOT NULL DEFAULT now()
);

COMMENT ON TABLE kyc_audit.player_screening_results IS 'PEP, Sanctions, and Adverse Media screening results for regulatory compliance. Retention: 5-10 years.';

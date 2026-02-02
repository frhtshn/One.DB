-- =============================================
-- Player KYC Provider Logs (KYC Provider Logları)
-- Harici KYC sağlayıcılarla yapılan API çağrıları
-- Sumsub, Onfido vb. entegrasyonları
-- TENANT_LOG DB - 90+ gün retention (KYC için uzatılmış)
-- =============================================

DROP TABLE IF EXISTS kyc_log.player_kyc_provider_logs CASCADE;

CREATE TABLE kyc_log.player_kyc_provider_logs (
    id bigserial PRIMARY KEY,

    player_id bigint NOT NULL,                    -- Oyuncu ID (tenant DB referans)
    kyc_case_id bigint NOT NULL,                  -- Bağlı KYC vakası ID (tenant DB referans)

    -- Sağlayıcı bilgileri
    provider_code varchar(50) NOT NULL,           -- Sağlayıcı kodu
    -- sumsub: Sumsub entegrasyonu
    -- onfido: Onfido entegrasyonu
    -- internal: Dahili doğrulama

    provider_reference varchar(100),              -- Sağlayıcı referans ID

    -- API çağrı detayları
    api_endpoint varchar(255),                    -- Çağrılan endpoint
    api_method varchar(10),                       -- HTTP method (GET, POST, etc.)

    -- Request/Response
    request_payload jsonb,                        -- API isteği (hassas veriler maskelenmeli)
    response_payload jsonb,                       -- API yanıtı

    -- Durum
    status varchar(30),                           -- İşlem durumu
    -- success: Başarılı
    -- failed: Başarısız
    -- timeout: Zaman aşımı

    http_status_code int,                         -- HTTP durum kodu
    error_message text,                           -- Hata mesajı (varsa)

    -- Performans
    response_time_ms int,                         -- Yanıt süresi (milisaniye)

    created_at timestamp NOT NULL DEFAULT now()
);

COMMENT ON TABLE kyc_log.player_kyc_provider_logs IS 'External KYC provider API call logs for integrations like Sumsub and Onfido. Retention: 90+ days (extended for KYC compliance).';

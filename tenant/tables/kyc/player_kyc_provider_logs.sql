-- =============================================
-- Player KYC Provider Logs (KYC Provider Logları)
-- Harici KYC sağlayıcılarla yapılan API çağrıları
-- Sumsub, Onfido vb. entegrasyonları
-- =============================================

DROP TABLE IF EXISTS kyc.player_kyc_provider_logs CASCADE;

CREATE TABLE kyc.player_kyc_provider_logs (
    id BIGSERIAL PRIMARY KEY,

    kyc_case_id BIGINT NOT NULL,                  -- Bağlı KYC vakası ID

    provider_code VARCHAR(50) NOT NULL,           -- Sağlayıcı kodu
    -- SUMSUB: Sumsub entegrasyonu
    -- ONFIDO: Onfido entegrasyonu
    -- INTERNAL: Dahili doğrulama

    provider_reference VARCHAR(100),              -- Sağlayıcı referans ID

    request_payload JSONB,                        -- API isteği (hassas veriler maskelenmeli)
    response_payload JSONB,                       -- API yanıtı

    status VARCHAR(30),                           -- İşlem durumu
    -- SUCCESS: Başarılı
    -- FAILED: Başarısız
    -- TIMEOUT: Zaman aşımı

    created_at TIMESTAMP NOT NULL DEFAULT now()
);


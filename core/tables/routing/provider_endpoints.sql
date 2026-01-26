-- =============================================
-- Tablo: routing.provider_endpoints
-- Açıklama: Provider API endpoint tanımları
-- Her provider'in API adreslerini ve endpoint türlerini tutar
-- Örnek: Pragmatic deposit_url, callback_url, game_launch_url
-- =============================================

DROP TABLE IF EXISTS routing.provider_endpoints CASCADE;

CREATE TABLE routing.provider_endpoints (
    id bigserial PRIMARY KEY,                              -- Benzersiz endpoint kimliği
    provider_id bigint NOT NULL,                           -- Provider ID (FK: catalog.providers)
    gateway_code varchar(50) NOT NULL,                     -- Gateway kodu: LIVE, STAGING, SANDBOX
    endpoint_type varchar(50) NOT NULL,                    -- Endpoint tipi: DEPOSIT, WITHDRAW, CALLBACK, GAME
    endpoint_url text NOT NULL,                            -- Tam API adresi
    is_active boolean NOT NULL DEFAULT true,               -- Aktif/pasif durumu
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now()  -- Son güncelleme zamanı
);

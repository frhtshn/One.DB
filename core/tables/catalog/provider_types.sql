-- =============================================
-- Tablo: catalog.provider_types
-- Açıklama: Provider tip kategorileri
-- Provider'ların hangi kategoride olduğunu belirler
-- Örnek: GAME, PAYMENT, SMS, KYC
-- =============================================

DROP TABLE IF EXISTS catalog.provider_types CASCADE;

CREATE TABLE catalog.provider_types (
    id bigserial PRIMARY KEY,                              -- Benzersiz tip kimliği
    provider_type_code varchar(30) NOT NULL,               -- Tip kodu: GAME, PAYMENT, SMS, KYC
    provider_type_name varchar(100) NOT NULL,              -- Tip görünen adı: Game Provider, Payment Gateway
    created_at timestamp without time zone NOT NULL DEFAULT now() -- Kayıt oluşturma zamanı
);

COMMENT ON TABLE catalog.provider_types IS 'Provider type categories defining the service category such as GAME, PAYMENT, SMS, KYC';

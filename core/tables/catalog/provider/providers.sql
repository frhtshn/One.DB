-- =============================================
-- Tablo: catalog.providers
-- Açıklama: Servis sağlayıcı kataloğu
-- Oyun, ödeme, SMS vb. tüm entegre servis sağlayıcıları
-- =============================================

DROP TABLE IF EXISTS catalog.providers CASCADE;

CREATE TABLE catalog.providers (
    id bigserial PRIMARY KEY,                              -- Benzersiz provider kimliği
    provider_type_id bigint NOT NULL,                      -- Provider tipi ID (FK: catalog.provider_types)
    provider_code varchar(50) NOT NULL,                    -- Sistem kodu: PRAGMATIC, EVOLUTION, PAYTR
    provider_name varchar(255) NOT NULL,                   -- Görünen ad: Pragmatic Play, Evolution Gaming
    logo_url varchar(500),                                 -- Provider logo URL'si (CDN veya harici)
    is_active boolean NOT NULL DEFAULT true,               -- Aktif/pasif durumu
    created_at timestamp without time zone NOT NULL DEFAULT now() -- Kayıt oluşturma zamanı
);

COMMENT ON TABLE catalog.providers IS 'Service provider catalog for games, payments, SMS, KYC and other integrated services';

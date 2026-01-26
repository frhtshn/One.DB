-- =============================================
-- Tablo: routing.provider_callbacks
-- Açıklama: Provider callback yapılandırmaları
-- Provider'lardan gelen callback isteklerinin
-- IP whitelist ve tür tanımlamalarını tutar
-- =============================================

DROP TABLE IF EXISTS routing.provider_callbacks CASCADE;

CREATE TABLE routing.provider_callbacks (
    id bigserial PRIMARY KEY,                              -- Benzersiz callback kimliği
    provider_id bigint NOT NULL,                           -- Provider ID (FK: catalog.providers)
    callback_type varchar(50) NOT NULL,                    -- Callback tipi: DEPOSIT, WIN, REFUND
    allowed_ip_ranges cidr[],                              -- İzin verilen IP aralıkları (CIDR formatında)
    is_active boolean NOT NULL DEFAULT true,               -- Aktif/pasif durumu
    created_at timestamp without time zone NOT NULL DEFAULT now() -- Kayıt oluşturma zamanı
);

-- =============================================
-- Tablo: core.client_currencies
-- Açıklama: Client para birimi etkinleştirme tablosu
-- Her client'in hangi para birimlerini kullanacağını belirler
-- =============================================

DROP TABLE IF EXISTS core.client_currencies CASCADE;

CREATE TABLE core.client_currencies (
    id bigserial PRIMARY KEY,                              -- Benzersiz kayıt kimliği
    client_id bigint NOT NULL,                             -- Client ID (FK: core.clients)
    currency_code character(3) NOT NULL,                   -- Para birimi kodu (FK: catalog.currencies)
    is_enabled boolean NOT NULL DEFAULT true,              -- Aktif/pasif durumu
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now()  -- Son güncelleme zamanı
);

COMMENT ON TABLE core.client_currencies IS 'Client currency enablement table defining which currencies are available for each client';

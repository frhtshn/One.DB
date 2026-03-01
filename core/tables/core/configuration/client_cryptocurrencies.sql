-- =============================================
-- Tablo: core.client_cryptocurrencies
-- Açıklama: Client kripto para birimi etkinleştirme tablosu
-- Her client'ın hangi kripto para birimlerini kullanacağını belirler
-- =============================================

DROP TABLE IF EXISTS core.client_cryptocurrencies CASCADE;

CREATE TABLE core.client_cryptocurrencies (
    id bigserial PRIMARY KEY,                              -- Benzersiz kayıt kimliği
    client_id bigint NOT NULL,                             -- Client ID (FK: core.clients)
    symbol varchar(20) NOT NULL,                           -- Kripto sembolü (FK: catalog.cryptocurrencies)
    is_enabled boolean NOT NULL DEFAULT true,              -- Aktif/pasif durumu
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now()  -- Son güncelleme zamanı
);

COMMENT ON TABLE core.client_cryptocurrencies IS 'Client cryptocurrency enablement table defining which cryptocurrencies are available for each client';

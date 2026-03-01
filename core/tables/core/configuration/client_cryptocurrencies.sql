-- =============================================
-- Tablo: core.tenant_cryptocurrencies
-- Açıklama: Tenant kripto para birimi etkinleştirme tablosu
-- Her tenant'ın hangi kripto para birimlerini kullanacağını belirler
-- =============================================

DROP TABLE IF EXISTS core.tenant_cryptocurrencies CASCADE;

CREATE TABLE core.tenant_cryptocurrencies (
    id bigserial PRIMARY KEY,                              -- Benzersiz kayıt kimliği
    tenant_id bigint NOT NULL,                             -- Tenant ID (FK: core.tenants)
    symbol varchar(20) NOT NULL,                           -- Kripto sembolü (FK: catalog.cryptocurrencies)
    is_enabled boolean NOT NULL DEFAULT true,              -- Aktif/pasif durumu
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now()  -- Son güncelleme zamanı
);

COMMENT ON TABLE core.tenant_cryptocurrencies IS 'Tenant cryptocurrency enablement table defining which cryptocurrencies are available for each tenant';

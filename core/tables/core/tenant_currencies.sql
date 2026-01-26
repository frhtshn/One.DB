-- =============================================
-- Tablo: core.tenant_currencies
-- Açıklama: Tenant para birimi etkinleştirme tablosu
-- Her tenant'in hangi para birimlerini kullanacağını belirler
-- =============================================

DROP TABLE IF EXISTS core.tenant_currencies CASCADE;

CREATE TABLE core.tenant_currencies (
    id bigserial PRIMARY KEY,                              -- Benzersiz kayıt kimliği
    tenant_id bigint NOT NULL,                             -- Tenant ID (FK: core.tenants)
    currency_code character(3) NOT NULL,                   -- Para birimi kodu (FK: catalog.currencies)
    is_enabled boolean NOT NULL DEFAULT true,              -- Aktif/pasif durumu
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now()  -- Son güncelleme zamanı
);

COMMENT ON TABLE core.tenant_currencies IS 'Tenant currency enablement table defining which currencies are available for each tenant';

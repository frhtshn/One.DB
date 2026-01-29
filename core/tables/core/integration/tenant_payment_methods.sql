-- =============================================
-- Tablo: core.tenant_payment_methods
-- Açıklama: Tenant ödeme yöntemi etkinleştirme tablosu
-- Her tenant'in hangi ödeme yöntemlerini sunacağını belirler
-- =============================================

DROP TABLE IF EXISTS core.tenant_payment_methods CASCADE;

CREATE TABLE core.tenant_payment_methods (
    id bigserial PRIMARY KEY,                              -- Benzersiz kayıt kimliği
    tenant_id bigint NOT NULL,                             -- Tenant ID (FK: core.tenants)
    payment_method_id bigint NOT NULL,                     -- Ödeme yöntemi ID (FK: catalog.payment_methods)
    is_enabled boolean NOT NULL DEFAULT true,              -- Aktif/pasif durumu
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now()  -- Son güncelleme zamanı
);

COMMENT ON TABLE core.tenant_payment_methods IS 'Tenant payment method enablement table defining which payment methods are available for each tenant';

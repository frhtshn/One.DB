-- =============================================
-- Tablo: core.tenant_languages
-- Açıklama: Tenant dil etkinleştirme tablosu
-- Her tenant'in hangi dilleri destekleyeceğini belirler
-- =============================================

DROP TABLE IF EXISTS core.tenant_languages CASCADE;

CREATE TABLE core.tenant_languages (
    id bigserial PRIMARY KEY,                              -- Benzersiz kayıt kimliği
    tenant_id bigint NOT NULL,                             -- Tenant ID (FK: core.tenants)
    language_code character(2) NOT NULL,                   -- Dil kodu (FK: catalog.languages)
    is_enabled boolean NOT NULL DEFAULT true,              -- Aktif/pasif durumu
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now()  -- Son güncelleme zamanı
);

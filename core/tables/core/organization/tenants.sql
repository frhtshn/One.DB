-- =============================================
-- Tablo: core.tenants
-- Açıklama: Tenant (kiřacı) ana tablosu
-- Her tenant bir marka/site/operasyonu temsil eder
-- Her tenant için ayrı bir veritabanı oluşturulur
-- =============================================

DROP TABLE IF EXISTS core.tenants CASCADE;

CREATE TABLE core.tenants (
    id bigserial PRIMARY KEY,                              -- Benzersiz tenant kimliği
    company_id bigint NOT NULL,                            -- Bağlı şirket ID (FK: core.companies)
    tenant_code varchar(50) NOT NULL,                      -- Tenant sistem kodu: acme_tr, acme_eu
    tenant_name varchar(255) NOT NULL,                     -- Tenant görünen adı
    environment varchar(20) NOT NULL DEFAULT 'prod',       -- Ortam: prod, staging, dev, shadow
    status smallint NOT NULL DEFAULT 1,                    -- Durum: 0=Pasif, 1=Aktif, 2=Askıda
    base_currency character(3),                            -- Ana para birimi (FK: catalog.currencies)
    default_language character(2),                         -- Varsayılan dil (FK: catalog.languages)
    default_country character(2),                          -- Varsayılan ülke (FK: catalog.countries)
    timezone varchar(50),                                  -- Saat dilimi: Europe/Istanbul
    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now()  -- Son güncelleme zamanı
);

COMMENT ON TABLE core.tenants IS 'Tenant master table where each tenant represents a brand, site, or operation with its own isolated database';

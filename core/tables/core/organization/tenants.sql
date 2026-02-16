-- =============================================
-- Tablo: core.tenants
-- Açıklama: Tenant (kiracı) ana tablosu
-- Her tenant bir marka/site/operasyonu temsil eder
-- Her tenant için ayrı bir veritabanı oluşturulur
-- Provisioning alanları: domain, hosting, durum takibi
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

    -- Domain Bilgileri (Provisioning)
    domain VARCHAR(255),                                  -- Ana domain: eurobet.com
    subdomain VARCHAR(255),                               -- Alt domain: app.eurobet.com, bo.eurobet.com

    -- Provisioning Durumu (ProductionManager tarafından yönetilir)
    -- status (0/1/2) = operasyonel durum, provisioning_status = altyapı durumu
    -- Tenant ACTIVE: status = 1 AND provisioning_status = 'active'
    provisioning_status VARCHAR(20) DEFAULT 'draft',      -- draft, pending, provisioning, active, failed, suspended, decommissioned
    provisioning_step VARCHAR(50),                         -- Son tamamlanan adım: VALIDATE, DB_PROVISION, DB_CREATE, ...
    provisioned_at TIMESTAMPTZ,                            -- İlk başarılı canlıya alınma zamanı
    decommissioned_at TIMESTAMPTZ,                         -- Kapatılma zamanı

    -- Hosting Modu
    hosting_mode VARCHAR(20) DEFAULT 'shared',             -- dedicated, shared

    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now()  -- Son güncelleme zamanı
);

COMMENT ON TABLE core.tenants IS 'Tenant master table where each tenant represents a brand, site, or operation with its own isolated database. Includes provisioning lifecycle fields managed by ProductionManager.';

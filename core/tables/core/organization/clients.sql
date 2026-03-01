-- =============================================
-- Tablo: core.clients
-- Açıklama: Client (client) ana tablosu
-- Her client bir marka/site/operasyonu temsil eder
-- Her client için ayrı bir veritabanı oluşturulur
-- Provisioning alanları: domain, hosting, durum takibi
-- =============================================

DROP TABLE IF EXISTS core.clients CASCADE;

CREATE TABLE core.clients (
    id bigserial PRIMARY KEY,                              -- Benzersiz client kimliği
    company_id bigint NOT NULL,                            -- Bağlı şirket ID (FK: core.companies)
    client_code varchar(50) NOT NULL,                      -- Client sistem kodu: acme_tr, acme_eu
    client_name varchar(255) NOT NULL,                     -- Client görünen adı
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
    -- Client ACTIVE: status = 1 AND provisioning_status = 'active'
    provisioning_status VARCHAR(20) DEFAULT 'draft',      -- draft, pending, provisioning, active, failed, suspended, decommissioned
    provisioning_step VARCHAR(50),                         -- Son tamamlanan adım: VALIDATE, DB_PROVISION, DB_CREATE, ...
    provisioned_at TIMESTAMPTZ,                            -- İlk başarılı canlıya alınma zamanı
    decommissioned_at TIMESTAMPTZ,                         -- Kapatılma zamanı

    -- Hosting Modu
    hosting_mode VARCHAR(20) DEFAULT 'shared',             -- dedicated, shared

    created_at timestamp without time zone NOT NULL DEFAULT now(), -- Kayıt oluşturma zamanı
    updated_at timestamp without time zone NOT NULL DEFAULT now()  -- Son güncelleme zamanı
);

COMMENT ON TABLE core.clients IS 'Client master table where each client represents a brand, site, or operation with its own isolated database. Includes provisioning lifecycle fields managed by ProductionManager.';

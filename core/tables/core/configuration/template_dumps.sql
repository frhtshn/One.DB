-- =============================================
-- Tablo: core.template_dumps
-- Açıklama: Template DB dump versiyonları
-- ProductionManager en güncel dump'ı kullanarak
-- yeni tenant DB'lerini pg_restore ile oluşturur.
-- Her DB tipi için ayrı dump kaydı tutulur.
-- =============================================

DROP TABLE IF EXISTS core.template_dumps CASCADE;

CREATE TABLE core.template_dumps (
    id BIGSERIAL PRIMARY KEY,                                     -- Benzersiz kayıt kimliği
    db_type VARCHAR(30) NOT NULL,                                  -- tenant, tenant_audit, tenant_log, tenant_report, tenant_affiliate
    version VARCHAR(50) NOT NULL,                                  -- Versiyon: 2026.02.12-001
    dump_path VARCHAR(500) NOT NULL,                               -- Dump konumu: s3://nucleo-dumps/tenant/2026.02.12-001.dump
    dump_size_bytes BIGINT,                                        -- Dump dosya boyutu

    -- Dump Formatı
    dump_format VARCHAR(20) DEFAULT 'custom',                      -- custom (pg_dump -Fc), directory, plain

    -- Schema Bilgisi
    schema_hash VARCHAR(64),                                       -- SHA256 of deploy script (değişiklik tespiti)
    migration_version VARCHAR(50),                                 -- Hangi migration seviyesine kadar

    -- Durum
    status VARCHAR(20) DEFAULT 'active',                           -- active, deprecated, failed
    tested_at TIMESTAMPTZ,                                         -- Test edilme zamanı
    notes TEXT,                                                    -- Versiyon notları

    -- Audit
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by BIGINT                                              -- Oluşturan (sistem veya kullanıcı)
);

COMMENT ON TABLE core.template_dumps IS 'Template DB dump versions for tenant provisioning. ProductionManager uses the latest active dump for pg_restore. Each of the 5 tenant DB types has separate dump entries.';

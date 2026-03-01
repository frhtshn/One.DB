-- =============================================
-- Tablo: core.tenant_servers
-- Açıklama: Tenant-sunucu atamaları
-- Her tenant component'inin hangi sunucuda çalıştığını tanımlar.
-- Provisioning sırasında container bilgileri yazılır.
-- =============================================

DROP TABLE IF EXISTS core.tenant_servers CASCADE;

CREATE TABLE core.tenant_servers (
    id BIGSERIAL PRIMARY KEY,                                     -- Benzersiz kayıt kimliği
    tenant_id BIGINT NOT NULL,                                    -- Tenant ID (FK: core.tenants)
    server_id BIGINT NOT NULL,                                    -- Sunucu ID (FK: core.infrastructure_servers)
    server_role VARCHAR(30) NOT NULL,                              -- db_primary, db_replica, db_failover, backend, callback, frontend

    -- Container Bilgileri (provisioning sonrası yazılır)
    container_id VARCHAR(100),                                    -- Docker container ID
    container_name VARCHAR(150),                                  -- nucleo_tenant_1_db_primary
    container_image VARCHAR(255),                                 -- postgres:16, nucleo/tenant-backend:latest
    container_port INTEGER,                                       -- Expose edilen port

    -- Durum
    status VARCHAR(20) DEFAULT 'pending',                         -- pending, creating, running, stopped, error, removed
    health_status VARCHAR(20) DEFAULT 'unknown',                  -- healthy, unhealthy, unknown
    health_endpoint VARCHAR(255),                                 -- http://host:8080/health
    last_health_at TIMESTAMPTZ,                                   -- Son health check zamanı

    -- Metadata
    environment_vars JSONB DEFAULT '{}',                          -- Container env vars (hassas bilgiler hariç)
    metadata JSONB DEFAULT '{}',                                  -- Ek bilgiler

    -- Audit
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE core.tenant_servers IS 'Tenant-to-server mapping with container details per role (db_primary, backend, frontend, etc). Updated during provisioning with container info and health status.';

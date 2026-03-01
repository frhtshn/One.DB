-- =============================================
-- Tablo: core.client_servers
-- Açıklama: Client-sunucu atamaları
-- Her client component'inin hangi sunucuda çalıştığını tanımlar.
-- Provisioning sırasında container bilgileri yazılır.
-- =============================================

DROP TABLE IF EXISTS core.client_servers CASCADE;

CREATE TABLE core.client_servers (
    id BIGSERIAL PRIMARY KEY,                                     -- Benzersiz kayıt kimliği
    client_id BIGINT NOT NULL,                                    -- Client ID (FK: core.clients)
    server_id BIGINT NOT NULL,                                    -- Sunucu ID (FK: core.infrastructure_servers)
    server_role VARCHAR(30) NOT NULL,                              -- db_primary, db_replica, db_failover, backend, callback, frontend

    -- Container Bilgileri (provisioning sonrası yazılır)
    container_id VARCHAR(100),                                    -- Docker container ID
    container_name VARCHAR(150),                                  -- so_client_1_db_primary
    container_image VARCHAR(255),                                 -- postgres:16, so/client-backend:latest
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

COMMENT ON TABLE core.client_servers IS 'Client-to-server mapping with container details per role (db_primary, backend, frontend, etc). Updated during provisioning with container info and health status.';

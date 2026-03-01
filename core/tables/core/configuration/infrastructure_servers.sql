-- =============================================
-- Tablo: core.infrastructure_servers
-- Açıklama: Fiziksel/sanal sunucu envanteri
-- ProductionManager buradan mevcut kapasiteyi okur.
-- Shared/dedicated sunucu tipi, region, sağlık durumu.
-- =============================================

DROP TABLE IF EXISTS core.infrastructure_servers CASCADE;

CREATE TABLE core.infrastructure_servers (
    id BIGSERIAL PRIMARY KEY,                                     -- Benzersiz sunucu kimliği
    server_code VARCHAR(50) NOT NULL,                             -- Sunucu kodu: aws-eu-fra-01, hetzner-de-fsn-02
    server_name VARCHAR(255),                                     -- Görünen ad: AWS Frankfurt #1

    -- Bağlantı Bilgileri
    host VARCHAR(255) NOT NULL,                                   -- IP/hostname: 52.59.123.45
    docker_host VARCHAR(255),                                     -- Docker API: tcp://52.59.123.45:2376
    docker_tls_verify BOOLEAN DEFAULT true,                       -- Docker TLS doğrulama

    -- Konum ve Provider
    region VARCHAR(50),                                           -- Bölge: eu-central-1, eu-west-1, tr-ist-1
    cloud_provider VARCHAR(50),                                   -- Bulut sağlayıcı: aws, hetzner, bare-metal
    availability_zone VARCHAR(50),                                -- Erişilebilirlik alanı: eu-central-1a

    -- Sunucu Tipi
    server_type VARCHAR(30) NOT NULL DEFAULT 'shared',            -- dedicated, shared
    server_purpose VARCHAR(30) NOT NULL DEFAULT 'all',            -- all, db_only, app_only

    -- Kapasite
    specs JSONB DEFAULT '{}',                                     -- {"cpu": 8, "ram_gb": 32, "disk_gb": 500, "disk_type": "nvme"}
    max_clients INTEGER DEFAULT 10,                               -- Bu sunucuda max kaç client
    current_clients INTEGER DEFAULT 0,                            -- Mevcut client sayısı

    -- Durum
    status VARCHAR(20) DEFAULT 'active',                          -- active, maintenance, full, decommissioned
    health_status VARCHAR(20) DEFAULT 'unknown',                  -- healthy, degraded, unhealthy, unknown
    last_health_at TIMESTAMPTZ,                                   -- Son health check zamanı
    health_metadata JSONB DEFAULT '{}',                           -- {"cpu_usage": 45, "ram_usage_pct": 72, "disk_free_gb": 180}

    -- Audit
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by BIGINT                                             -- Ekleyen kullanıcı
);

COMMENT ON TABLE core.infrastructure_servers IS 'Physical/virtual server inventory for client provisioning. Tracks capacity, health, and hosting type (dedicated/shared). Read by ProductionManager.';

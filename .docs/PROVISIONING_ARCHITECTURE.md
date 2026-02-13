# Whitelabel Provisioning Sistemi - Tam Mimari Plan

## Context

Yeni whitelabel (tenant) açılışından canlıya alınmasına kadar tam provisioning yaşam döngüsü. Mevcut `core.tenant_create` fonksiyonu sadece Core DB'ye kayıt açıyor; altyapı oluşturma, DB migration, seed ve servis deployment yok. Bu plan hem DB katmanındaki eksikleri hem de ProductionManager servis mimarisini kapsar.

**Senaryo Özeti:**
1. BO User (Platform Admin) yeni company oluşturur (gerekiyorsa)
2. Company altına yeni tenant eklenir
3. Tenant ayarları girilir (DB settings, providerlar, currencies, domain vb.)
4. "Canlıya Al" butonuna basılır
5. Hedef sunucuda PostgreSQL cluster (3 node Docker container) kurulur
6. Template DB dump'tan 5 tenant DB restore edilir
7. Tenant-specific veriler seed edilir (transaction_types, operation_types, initial partitions)
8. Tenant backend + callback + frontend container'ları ayağa kaldırılır
9. Health check geçerse tenant ACTIVE olur

**Kararlar:**
- **ProductionManager**: CryptoManager/IpManager pattern'inde gRPC servis. Provisioning orchestration + basit health check.
- **Altyapı**: AWS üzerinde Docker container'lar. Büyük tenantlar dedicated sunucu, küçükler shared.
- **DB kurulumu**: Template tenant'tan pg_dump ile hazırlanmış dump dosyasından restore (hızlı, saniyeler).
- **Deploy scriptleri**: Template dump güncel değilse fallback olarak deploy_*.sql scriptleri çalıştırılabilir.
- **Monitoring**: ProductionManager'da basit health check (alive/dead + disk/RAM alert). Full Grafana stack ayrı concern.
- **Docker API**: Sunuculara SSH yerine Docker API (TCP:2376, TLS) üzerinden uzak container yönetimi.
- **Provisioning state**: Core DB'de step-by-step takip. Yarıda kalan işlem kaldığı yerden devam eder (idempotent).
- **Server envanteri**: Core DB'de `core.infrastructure_servers` + `core.tenant_servers` tabloları.
- **Config auto-populate**: Provisioning sırasında connection string'ler, secrets ve routing otomatik oluşturulur.

---

## Mevcut Durum

### Core DB'de VAR Olanlar

| Tablo/Fonksiyon | Durum | Eksik |
|---|---|---|
| `core.tenants` | **DEPLOYED** | domain, provisioning_status, provisioning_step yok |
| `core.companies` | **DEPLOYED** | OK |
| `core.tenant_settings` | **DEPLOYED** | Auto-populate fonksiyonu yok |
| `core.tenant_currencies` | **DEPLOYED** | OK (tenant_create'te populate) |
| `core.tenant_languages` | **DEPLOYED** | OK (tenant_create'te populate) |
| `core.tenant_jurisdictions` | **DEPLOYED** | OK |
| `core.tenant_providers` | **DEPLOYED** | OK (fonksiyonlar Game/Finance planlarında) |
| `security.secrets_tenant` | **DEPLOYED** | Auto-generate fonksiyonu yok |
| `routing.callback_routes` | **DEPLOYED** | Auto-setup fonksiyonu yok |
| `core.tenant_create` | **DEPLOYED** | Sadece kayıt açar, altyapı/seed yok |
| `core.tenant_update/delete/get/list/lookup` | **DEPLOYED** | OK |
| `core.tenant_setting_upsert` | **DEPLOYED** | OK |

### OLMAYAN / EKSİK Olanlar

| Eksik | Açıklama |
|-------|----------|
| **Server envanteri tablosu** | Fiziksel/sanal sunucu listesi yok |
| **Tenant-server mapping** | Hangi tenant hangi sunucuda çalışıyor bilgisi yok |
| **Provisioning log tablosu** | Adım takibi yok |
| **Provisioning status alanları** | `core.tenants`'ta domain, provisioning state yok |
| **Config auto-populate** | Connection string, secret, routing otomatik oluşturma yok |
| **Template dump yönetimi** | Template DB dump versiyonu/konumu bilgisi yok |
| **ProductionManager servisi** | Henüz yok (bu plan ile tasarlanacak) |

### Mevcut Tenant Oluşturma Akışı (Eksik)

```
Şu an:
  1. BO -> tenant_create(company, code, name, currency, languages)
  2. Core DB'ye tenant kaydı + currencies + languages eklenir
  3. BİTTİ. Altyapı yok, DB yok, servis yok.

Olması gereken:
  1. BO -> tenant_create (draft olarak)
  2. BO -> settings, providers, servers atanır
  3. BO -> "Canlıya Al" butonu
  4. ProductionManager -> 11 adımlık provisioning
  5. Tenant ACTIVE
```

---

## Mimari Genel Bakış

### Servis Mimarisi

```
┌──────────────────────────────────────────────────┐
│  NUCLEO BACKOFFICE (BO UI)                       │
│  Company oluştur → Tenant oluştur → Ayarla       │
│  "Canlıya Al" butonu                             │
└─────────────────┬────────────────────────────────┘
                  │ gRPC
┌─────────────────▼────────────────────────────────┐
│  NUCLEO CORE BACKEND                             │
│  tenant_create, tenant_settings, IDOR            │
│  ProvisionTenant gRPC call →                     │
└─────────────────┬────────────────────────────────┘
                  │ gRPC
┌─────────────────▼────────────────────────────────┐
│  PRODUCTION MANAGER (.NET gRPC Service)          │
│                                                  │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────┐ │
│  │ Provisioning│  │ Docker       │  │ Health  │ │
│  │ Engine      │  │ Client       │  │ Checker │ │
│  │ (State Mc.) │  │ (Remote API) │  │ (Poll)  │ │
│  └──────┬──────┘  └──────┬───────┘  └────┬────┘ │
│         │                │               │      │
│         └────────┬───────┘               │      │
│                  │                       │      │
│         ┌───────▼────────┐    ┌─────────▼────┐  │
│         │ Core DB        │    │ Target       │  │
│         │ (State R/W)    │    │ Servers      │  │
│         └────────────────┘    └──────────────┘  │
└──────────────────────────────────────────────────┘
```

### Altyapı Topolojisi

```
DEDICATED TENANT (Büyük trafik):
┌──────────────────────────────────┐
│ AWS VPS / VDC (Dedicated)        │
│                                  │
│  ┌─────────────────────────────┐ │
│  │ PostgreSQL Primary  :5432   │ │
│  │ PostgreSQL Replica  :5433   │ │
│  │ PostgreSQL Failover :5434   │ │
│  └─────────────────────────────┘ │
│  ┌─────────────────────────────┐ │
│  │ Tenant Backend      :8080   │ │
│  │ Callback Service    :8081   │ │
│  │ Nginx + Vue         :443    │ │
│  └─────────────────────────────┘ │
└──────────────────────────────────┘

SHARED CLUSTER (Küçük trafik):
┌──────────────────────────────────┐
│ AWS VPS / VDC (Shared)           │
│                                  │
│  ┌─────────────────────────────┐ │
│  │ PostgreSQL Cluster          │ │
│  │ ├─ tenant_1, tenant_2, ... │ │
│  │ ├─ tenant_audit_1, ...     │ │
│  │ └─ (Tüm tenant DB'leri)   │ │
│  └─────────────────────────────┘ │
│  ┌─────────────────────────────┐ │
│  │ Tenant Backend #1   :8080   │ │
│  │ Tenant Backend #2   :8082   │ │
│  │ Callback Service    :8081   │ │
│  │ Nginx (multi-tenant):443    │ │
│  └─────────────────────────────┘ │
└──────────────────────────────────┘
```

---

## ADIM 1: Tablo Değişiklikleri

### 1A. MODIFY: `core.tenants` (Core DB)

Dosya: `core/tables/core/organization/tenants.sql`

Mevcut tabloya eklenen alanlar:
```
-- Domain Bilgileri
domain                  VARCHAR(255),                   -- Ana domain: eurobet.com
subdomain               VARCHAR(255),                   -- Alt domain: app.eurobet.com, bo.eurobet.com

-- Provisioning Durumu
provisioning_status     VARCHAR(20) DEFAULT 'draft',    -- draft, pending, provisioning, active, failed, suspended, decommissioned
provisioning_step       VARCHAR(50),                    -- Son tamamlanan adım: VALIDATE, DB_PROVISION, DB_CREATE, ...
provisioned_at          TIMESTAMP,                      -- İlk başarılı canlıya alınma zamanı
decommissioned_at       TIMESTAMP,                      -- Kapatılma zamanı

-- Hosting Modu
hosting_mode            VARCHAR(20) DEFAULT 'shared',   -- dedicated, shared
```

> **status vs provisioning_status ayrımı:**
> `status` (0/1/2) = Operasyonel durum (Pasif/Aktif/Askıda). Admin tarafından değiştirilebilir.
> `provisioning_status` = Altyapı durumu. ProductionManager tarafından yönetilir.
> Tenant ACTIVE olması için: `status = 1 AND provisioning_status = 'active'`

### 1B. YENİ TABLO: `core.infrastructure_servers` (Core DB)

Fiziksel/sanal sunucu envanteri. ProductionManager buradan mevcut kapasiteyi okur.

Dosya: `core/tables/core/configuration/infrastructure_servers.sql`

```
core.infrastructure_servers
  id                  BIGSERIAL PK
  server_code         VARCHAR(50) NOT NULL UNIQUE       -- aws-eu-fra-01, hetzner-de-fsn-02
  server_name         VARCHAR(255)                      -- AWS Frankfurt #1
  host                VARCHAR(255) NOT NULL             -- 52.59.123.45
  docker_host         VARCHAR(255)                      -- tcp://52.59.123.45:2376
  docker_tls_verify   BOOLEAN DEFAULT true              -- Docker TLS doğrulama

  -- Konum ve Provider
  region              VARCHAR(50)                       -- eu-central-1, eu-west-1, tr-ist-1
  cloud_provider      VARCHAR(50)                       -- aws, hetzner, bare-metal
  availability_zone   VARCHAR(50)                       -- eu-central-1a

  -- Sunucu Tipi
  server_type         VARCHAR(30) NOT NULL DEFAULT 'shared'  -- dedicated, shared
  server_purpose      VARCHAR(30) NOT NULL DEFAULT 'all'     -- all, db_only, app_only

  -- Kapasite
  specs               JSONB DEFAULT '{}'                -- {"cpu": 8, "ram_gb": 32, "disk_gb": 500, "disk_type": "nvme"}
  max_tenants         INTEGER DEFAULT 10                -- Bu sunucuda max kaç tenant
  current_tenants     INTEGER DEFAULT 0                 -- Mevcut tenant sayısı

  -- Durum
  status              VARCHAR(20) DEFAULT 'active'      -- active, maintenance, full, decommissioned
  health_status       VARCHAR(20) DEFAULT 'unknown'     -- healthy, degraded, unhealthy, unknown
  last_health_at      TIMESTAMP                         -- Son health check zamanı
  health_metadata     JSONB DEFAULT '{}'                -- {"cpu_usage": 45, "ram_usage_pct": 72, "disk_free_gb": 180}

  -- Audit
  created_at          TIMESTAMP DEFAULT now()
  updated_at          TIMESTAMP DEFAULT now()
  created_by          BIGINT                            -- Ekleyen kullanıcı
```

### 1C. YENİ TABLO: `core.tenant_servers` (Core DB)

Her tenant component'inin hangi sunucuda çalıştığını tanımlar.

Dosya: `core/tables/core/configuration/tenant_servers.sql`

```
core.tenant_servers
  id                  BIGSERIAL PK
  tenant_id           BIGINT NOT NULL                   -- FK: core.tenants
  server_id           BIGINT NOT NULL                   -- FK: core.infrastructure_servers
  server_role         VARCHAR(30) NOT NULL              -- db_primary, db_replica, db_failover, backend, callback, frontend

  -- Container Bilgileri (provisioning sonrası yazılır)
  container_id        VARCHAR(100)                      -- Docker container ID
  container_name      VARCHAR(150)                      -- nucleo_tenant_1_db_primary
  container_image     VARCHAR(255)                      -- postgres:16, nucleo/tenant-backend:latest
  container_port      INTEGER                           -- Expose edilen port

  -- Durum
  status              VARCHAR(20) DEFAULT 'pending'     -- pending, creating, running, stopped, error, removed
  health_status       VARCHAR(20) DEFAULT 'unknown'     -- healthy, unhealthy, unknown
  health_endpoint     VARCHAR(255)                      -- http://host:8080/health
  last_health_at      TIMESTAMP

  -- Metadata
  environment_vars    JSONB DEFAULT '{}'                -- Container env vars (hassas bilgiler hariç)
  metadata            JSONB DEFAULT '{}'                -- Ek bilgiler

  -- Audit
  created_at          TIMESTAMP DEFAULT now()
  updated_at          TIMESTAMP DEFAULT now()
```

> **server_role değerleri:**
> - `db_primary`: PostgreSQL primary node (read-write)
> - `db_replica`: PostgreSQL replica (read-only)
> - `db_failover`: PostgreSQL failover standby
> - `backend`: Tenant backend API service
> - `callback`: Provider callback handler service
> - `frontend`: Nginx + Vue frontend

### 1D. YENİ TABLO: `core.tenant_provisioning_log` (Core DB)

Provisioning adım takibi. Her step bir kayıt. Retry ve hata takibi.

Dosya: `core/tables/core/configuration/tenant_provisioning_log.sql`

```
core.tenant_provisioning_log
  id                  BIGSERIAL PK
  tenant_id           BIGINT NOT NULL                   -- FK: core.tenants
  provision_run_id    UUID NOT NULL                     -- Aynı provisioning denemesinin ID'si
  step_name           VARCHAR(50) NOT NULL              -- VALIDATE, DB_PROVISION, DB_CREATE, ...
  step_order          SMALLINT NOT NULL                 -- 1, 2, 3, ...

  -- Durum
  status              VARCHAR(20) NOT NULL DEFAULT 'pending'  -- pending, running, completed, failed, skipped, rolled_back
  started_at          TIMESTAMP
  completed_at        TIMESTAMP
  duration_ms         INTEGER                           -- Süre (millisaniye)

  -- Hata Takibi
  error_message       TEXT                              -- Hata mesajı
  error_detail        TEXT                              -- Stack trace / detay
  retry_count         SMALLINT DEFAULT 0                -- Retry sayısı
  max_retries         SMALLINT DEFAULT 3                -- Max retry

  -- Step Çıktısı
  output              JSONB DEFAULT '{}'                -- Step-specific çıktılar
                                                        -- DB_CREATE: {"databases": ["tenant_1", "tenant_audit_1", ...]}
                                                        -- BACKEND_DEPLOY: {"container_id": "abc123", "port": 8080}
                                                        -- HEALTH_CHECK: {"checks": [{"service": "db", "ok": true}, ...]}

  -- Audit
  created_at          TIMESTAMP DEFAULT now()
```

### 1E. YENİ TABLO: `core.template_dumps` (Core DB)

Template DB dump versiyonlarını takip eder. ProductionManager en güncel dump'ı kullanır.

Dosya: `core/tables/core/configuration/template_dumps.sql`

```
core.template_dumps
  id                  BIGSERIAL PK
  db_type             VARCHAR(30) NOT NULL              -- tenant, tenant_audit, tenant_log, tenant_report, tenant_affiliate
  version             VARCHAR(50) NOT NULL              -- 2026.02.12-001
  dump_path           VARCHAR(500) NOT NULL             -- s3://nucleo-dumps/tenant/2026.02.12-001.dump
  dump_size_bytes     BIGINT                            -- Dump dosya boyutu
  dump_format         VARCHAR(20) DEFAULT 'custom'      -- custom (pg_dump -Fc), directory, plain

  -- Schema Bilgisi
  schema_hash         VARCHAR(64)                       -- SHA256 of deploy script (değişiklik tespiti)
  migration_version   VARCHAR(50)                       -- Hangi migration seviyesine kadar

  -- Durum
  status              VARCHAR(20) DEFAULT 'active'      -- active, deprecated, failed
  created_at          TIMESTAMP DEFAULT now()
  created_by          BIGINT                            -- Oluşturan (sistem veya kullanıcı)
  tested_at           TIMESTAMP                         -- Test edilme zamanı
  notes               TEXT                              -- Versiyon notları

  UNIQUE(db_type, version)
```

### 1F. Constraint ve Index Güncellemeleri

**Core** (`core/constraints/core.sql`):
- `fk_tenant_servers_tenant` FK → core.tenants(id)
- `fk_tenant_servers_server` FK → core.infrastructure_servers(id)
- `uq_tenant_servers_role` UNIQUE(tenant_id, server_id, server_role)
- `fk_provisioning_log_tenant` FK → core.tenants(id)
- `fk_template_dumps_type_version` UNIQUE(db_type, version)

**Core** (`core/indexes/core.sql`):
- `idx_infrastructure_servers_status` WHERE status = 'active'
- `idx_infrastructure_servers_type` BTREE(server_type)
- `idx_infrastructure_servers_region` BTREE(region)
- `idx_tenant_servers_tenant` BTREE(tenant_id)
- `idx_tenant_servers_server` BTREE(server_id)
- `idx_tenant_servers_status` WHERE status = 'running'
- `idx_provisioning_log_tenant` BTREE(tenant_id)
- `idx_provisioning_log_run` BTREE(provision_run_id)
- `idx_provisioning_log_status` WHERE status IN ('running', 'failed')
- `idx_template_dumps_active` WHERE status = 'active'

---

## ADIM 2: Fonksiyonlar (14 fonksiyon)

### Grup A: Core - Infrastructure Server Yönetimi (4)

Klasör: `core/functions/core/infrastructure/`
Tümü: SUPER_ADMIN korumalı

| # | Dosya | Açıklama | Return |
|---|-------|----------|--------|
| 1 | `infrastructure_server_create.sql` | Yeni sunucu envantere ekle | BIGINT (server id) |
| 2 | `infrastructure_server_update.sql` | Sunucu bilgileri güncelle (COALESCE) | VOID |
| 3 | `infrastructure_server_get.sql` | Tekil sunucu detay | JSONB |
| 4 | `infrastructure_server_list.sql` | Sunucu listesi (filtre: region, type, status, capacity) | JSONB |

**infrastructure_server_create detay:**
```
Params: p_caller_id, p_server_code, p_server_name, p_host, p_docker_host,
        p_region, p_cloud_provider, p_availability_zone,
        p_server_type ('dedicated'/'shared'), p_server_purpose ('all'/'db_only'/'app_only'),
        p_specs JSONB, p_max_tenants

Validasyon:
  - Caller role_level >= 100 (SUPER_ADMIN)
  - server_code UNIQUE
  - host NOT NULL
Return: server id
```

**infrastructure_server_list detay:**
```
Params: p_caller_id, p_region?, p_server_type?, p_status?, p_has_capacity? BOOLEAN

p_has_capacity = true → WHERE current_tenants < max_tenants (boş kapasiteli sunucular)
JSONB fields: id, serverCode, serverName, host, region, cloudProvider,
              serverType, serverPurpose, specs, maxTenants, currentTenants,
              availableSlots (computed), status, healthStatus, lastHealthAt
ORDER BY: region, server_code
```

---

### Grup B: Core - Tenant Server Ataması (3)

Klasör: `core/functions/core/tenant_servers/`
Tümü: IDOR korumalı (user_assert_access_company)

| # | Dosya | Açıklama | Return |
|---|-------|----------|--------|
| 5 | `tenant_server_assign.sql` | Tenant'a sunucu ata (role bazlı) | BIGINT |
| 6 | `tenant_server_update.sql` | Container bilgisi güncelle (provisioning sırasında) | VOID |
| 7 | `tenant_server_list.sql` | Tenant'ın tüm sunucu/container listesi | JSONB |

**tenant_server_assign detay:**
```
Params: p_caller_id, p_tenant_id, p_server_id, p_server_role,
        p_container_image?, p_container_port?, p_health_endpoint?

Validasyon:
  - IDOR (tenant → company → caller check)
  - server_id EXISTS in infrastructure_servers AND status = 'active'
  - UNIQUE(tenant_id, server_id, server_role) kontrolü
  - Shared sunucularda capacity check (current_tenants < max_tenants)

UPSERT: (tenant_id, server_id, server_role)
Shared sunucuda: current_tenants++ (yeni atama ise)
```

**tenant_server_update detay:**
```
Params: p_tenant_id, p_server_role, p_container_id?, p_container_name?,
        p_status?, p_health_status?, p_environment_vars?, p_metadata?

ProductionManager tarafından çağrılır (p_caller_id = -1 SystemCallerId).
Provisioning step'leri sırasında container bilgilerini yazar.
```

---

### Grup C: Core - Provisioning Yönetimi (5)

Klasör: `core/functions/core/provisioning/`

| # | Dosya | Açıklama | Return |
|---|-------|----------|--------|
| 8 | `tenant_provision_start.sql` | Provisioning başlat (status=provisioning, log entries oluştur) | UUID (run_id) |
| 9 | `tenant_provision_step_update.sql` | Adım durumu güncelle (running/completed/failed) | VOID |
| 10 | `tenant_provision_complete.sql` | Provisioning başarılı bitir (status=active) | VOID |
| 11 | `tenant_provision_fail.sql` | Provisioning başarısız (status=failed, hata kaydet) | VOID |
| 12 | `tenant_provision_status.sql` | Provisioning durumu sorgula (tüm adımlar) | JSONB |

**tenant_provision_start detay:**
```
Params: p_tenant_id BIGINT

Validasyon:
  - Tenant EXISTS ve provisioning_status IN ('draft', 'failed')
  - Gerekli server atamaları yapılmış mı? (en az db_primary + backend + frontend)
  - Settings tamam mı? (domain mevcut mu?)

İşlem:
  1. UPDATE core.tenants SET provisioning_status = 'provisioning', provisioning_step = 'VALIDATE'
  2. UUID v_run_id = gen_random_uuid()
  3. INSERT 11 adım tenant_provisioning_log'a (status='pending'):
     VALIDATE(1), DB_PROVISION(2), DB_CREATE(3), DB_MIGRATE(4), DB_SEED(5),
     WRITE_CONFIG(6), BACKEND_DEPLOY(7), CALLBACK_DEPLOY(8), FRONTEND_DEPLOY(9),
     HEALTH_CHECK(10), ACTIVATE(11)
  4. RETURN v_run_id

NOT: ProductionManager bu run_id ile adımları takip eder.
```

**tenant_provision_step_update detay:**
```
Params: p_tenant_id, p_run_id UUID, p_step_name, p_status,
        p_error_message? TEXT, p_error_detail? TEXT, p_output? JSONB

İşlem:
  1. UPDATE tenant_provisioning_log SET status, started_at/completed_at, duration, error, output
  2. UPDATE core.tenants SET provisioning_step = p_step_name
  3. p_status = 'failed' → retry_count++

p_output örnekleri:
  DB_CREATE:       {"databases": ["tenant_1", "tenant_audit_1", "tenant_log_1", "tenant_report_1", "tenant_affiliate_1"]}
  DB_MIGRATE:      {"method": "pg_restore", "dump_version": "2026.02.12-001", "duration_sec": 12}
  DB_SEED:         {"transaction_types": 47, "operation_types": 5, "partitions_created": 15}
  BACKEND_DEPLOY:  {"container_id": "abc123def", "image": "nucleo/tenant-backend:2.1.0", "port": 8080}
  HEALTH_CHECK:    {"checks": [{"service": "db_primary", "ok": true}, {"service": "backend", "ok": true, "latency_ms": 45}]}
```

**tenant_provision_complete detay:**
```
Params: p_tenant_id, p_run_id UUID

Validasyon: Tüm adımlar 'completed' veya 'skipped' olmalı

İşlem:
  1. UPDATE core.tenants SET provisioning_status = 'active', provisioned_at = now()
  2. Outbox event: 'tenant_provisioned' (tenant_id, run_id)
```

**tenant_provision_status detay:**
```
Params: p_caller_id, p_tenant_id

IDOR + JSONB return: {
  tenantId, tenantCode, provisioningStatus, provisioningStep,
  currentRunId,
  steps: [
    {stepName: "VALIDATE", stepOrder: 1, status: "completed", durationMs: 150, completedAt: "..."},
    {stepName: "DB_PROVISION", stepOrder: 2, status: "running", startedAt: "..."},
    {stepName: "DB_CREATE", stepOrder: 3, status: "pending"},
    ...
  ],
  servers: [
    {role: "db_primary", host: "52.59.123.45", status: "running", healthStatus: "healthy"},
    ...
  ]
}
```

---

### Grup D: Core - Config Auto-Populate (2)

Klasör: `core/functions/core/provisioning/`

| # | Dosya | Açıklama | Return |
|---|-------|----------|--------|
| 13 | `tenant_config_auto_populate.sql` | Connection string + default settings otomatik oluştur | VOID |
| 14 | `tenant_secrets_generate.sql` | JWT key + encryption key placeholder oluştur | VOID |

**tenant_config_auto_populate detay:**
```
Params: p_tenant_id BIGINT

Tenant server bilgilerinden otomatik ayar oluşturur:

1. DB Connection Strings (5 adet):
   - core.tenant_servers WHERE server_role = 'db_primary' → host, port
   - Her DB tipi için connection string template:
     connection_tenant:           tenant_{id}
     connection_tenant_audit:     tenant_audit_{id}
     connection_tenant_log:       tenant_log_{id}
     connection_tenant_report:    tenant_report_{id}
     connection_tenant_affiliate: tenant_affiliate_{id}

   JSONB format:
   {
     "host": "{server_host}",
     "port": 5432,
     "database": "tenant_{id}",
     "username": "nucleo_tenant_{id}",
     "password": "auto_generated",
     "ssl_mode": "require",
     "min_pool_size": 5,
     "max_pool_size": 50,
     "replica_enabled": true,
     "replica_host": "{replica_server_host}",
     "replica_port": 5432
   }

2. Default Settings:
   - Security/password_expiry_days: 30
   - Security/password_history_count: 3
   - Security/password_min_length: 8

3. tenant_setting_upsert ile her birini yaz (ON CONFLICT güncelle)
```

**tenant_secrets_generate detay:**
```
Params: p_tenant_id, p_environment VARCHAR DEFAULT 'production'

İşlem:
  1. JWT_SECRET placeholder INSERT (gerçek değer ProductionManager tarafından yazılır)
  2. ENCRYPTION_KEY placeholder INSERT
  3. API_KEY placeholder INSERT

NOT: Gerçek secret değerleri ProductionManager'da üretilir ve
     security.secrets_tenant tablosuna backend üzerinden yazılır.
     Bu fonksiyon sadece placeholder kayıtları oluşturur.
```

---

## ADIM 3: Provisioning Akış Diyagramı

### Tam Akış: BO → Canlı Tenant

```
═══════════════════════════════════════════════════════
FAZA 1: HAZIRLIK (BO'da, manuel)
═══════════════════════════════════════════════════════

BO User (Platform Admin):
  1. Company oluştur (varsa atla)
     -> core.company_create(caller, code, name, country, timezone)

  2. Tenant oluştur (draft olarak)
     -> core.tenant_create(caller, company, code, name, env, currency, lang)
     -> provisioning_status = 'draft'

  3. Ayarları gir:
     -> Currencies + Languages (tenant_create'te otomatik)
     -> Jurisdictions (tenant_jurisdiction ata)
     -> Domain bilgisi (tenant_update ile domain set)
     -> Hosting mode: dedicated veya shared

  4. Sunucu ata:
     -> infrastructure_server_list(has_capacity=true) → uygun sunucular
     -> tenant_server_assign(tenant, server, 'db_primary')
     -> tenant_server_assign(tenant, server, 'db_replica')
     -> tenant_server_assign(tenant, server, 'db_failover')
     -> tenant_server_assign(tenant, server, 'backend')
     -> tenant_server_assign(tenant, server, 'callback')
     -> tenant_server_assign(tenant, server, 'frontend')

  5. Provider seçimi (opsiyonel, sonra da yapılabilir):
     -> Game provider'lar: tenant_provider_enable (Game planından)
     -> Payment provider'lar: tenant_payment_provider_enable (Finance planından)

═══════════════════════════════════════════════════════
FAZA 2: PROVISIONING (Otomatik, ProductionManager)
═══════════════════════════════════════════════════════

BO "Canlıya Al" butonu
  -> Core Backend -> gRPC: ProductionManager.ProvisionTenant(tenant_id)
  -> tenant_provision_start(tenant_id) → run_id

  ┌─────────────────────────────────────────────────────┐
  │ Step 1: VALIDATE                                    │
  │                                                     │
  │ Core DB'den oku:                                    │
  │   - core.tenants (tenant config)                    │
  │   - core.tenant_servers (server atamaları)          │
  │   - core.infrastructure_servers (server detayları)  │
  │                                                     │
  │ Kontroller:                                         │
  │   - domain set mi?                                  │
  │   - en az 1 DB server + 1 backend + 1 frontend?     │
  │   - base_currency set mi?                           │
  │   - server'lar erişilebilir mi? (Docker API ping)   │
  │                                                     │
  │ Başarısız → tenant_provision_fail + STOP            │
  ├─────────────────────────────────────────────────────┤
  │ Step 2: DB_PROVISION                                │
  │                                                     │
  │ Dedicated mode:                                     │
  │   Docker API → PostgreSQL container oluştur:        │
  │   - Primary: postgres:16 (port 5432)                │
  │   - Replica: postgres:16 (streaming replication)    │
  │   - Failover: postgres:16 (standby)                 │
  │   Container ready → tenant_server_update(container) │
  │                                                     │
  │ Shared mode:                                        │
  │   PostgreSQL cluster zaten çalışıyor                │
  │   Sadece DB user oluştur: nucleo_tenant_{id}        │
  │   → Bu adım SKIP edilebilir                         │
  ├─────────────────────────────────────────────────────┤
  │ Step 3: DB_CREATE                                   │
  │                                                     │
  │ 5 veritabanı oluştur:                               │
  │   CREATE DATABASE tenant_{id}                       │
  │   CREATE DATABASE tenant_audit_{id}                 │
  │   CREATE DATABASE tenant_log_{id}                   │
  │   CREATE DATABASE tenant_report_{id}                │
  │   CREATE DATABASE tenant_affiliate_{id}             │
  │                                                     │
  │ output: {"databases": [...], "user": "nucleo_t_1"}  │
  ├─────────────────────────────────────────────────────┤
  │ Step 4: DB_MIGRATE                                  │
  │                                                     │
  │ Template dump'tan restore (tercih edilen yöntem):   │
  │   1. core.template_dumps'tan en güncel dump_path al │
  │   2. S3'ten dump'ı indir                            │
  │   3. pg_restore -d tenant_{id} < tenant.dump        │
  │   4. Aynısı 4 DB için daha                          │
  │                                                     │
  │ Fallback (dump yoksa veya eskiyse):                 │
  │   psql -d tenant_{id} -f deploy_tenant.sql          │
  │   psql -d tenant_audit_{id} -f deploy_tenant_audit  │
  │   ...                                               │
  │                                                     │
  │ output: {"method": "pg_restore", "version": "..."}  │
  ├─────────────────────────────────────────────────────┤
  │ Step 5: DB_SEED                                     │
  │                                                     │
  │ Core DB'den tenant DB'ye veri kopyala:              │
  │   - catalog.transaction_types → finance.txn_types   │
  │   - catalog.operation_types → finance.op_types      │
  │   - Initial partitions oluştur (3-6 ay ilerisi)     │
  │     - transactions: monthly                         │
  │     - player_messages: monthly                      │
  │     - tenant_log tables: daily (30 gün)             │
  │     - tenant_audit tables: daily + monthly          │
  │     - tenant_report tables: monthly                 │
  │     - tenant_affiliate tables: monthly              │
  │                                                     │
  │ NOT: Provider/game/payment seed bu adımda DEĞİL.    │
  │ Bunlar provider enable akışıyla ayrıca yapılır.     │
  │                                                     │
  │ output: {"types": 52, "partitions": N}              │
  ├─────────────────────────────────────────────────────┤
  │ Step 6: WRITE_CONFIG                                │
  │                                                     │
  │ Core DB'ye otomatik config yaz:                     │
  │   - tenant_config_auto_populate(tenant_id)          │
  │     → 5 DB connection string                        │
  │     → Default security settings                     │
  │   - tenant_secrets_generate(tenant_id)              │
  │     → JWT_SECRET, ENCRYPTION_KEY                    │
  │   - routing.callback_routes oluştur                 │
  │     → Her provider için route_key                   │
  │                                                     │
  │ output: {"settings": 8, "secrets": 3, "routes": N}  │
  ├─────────────────────────────────────────────────────┤
  │ Step 7: BACKEND_DEPLOY                              │
  │                                                     │
  │ Docker API → Tenant backend container:              │
  │   Image: nucleo/tenant-backend:latest               │
  │   Env: TENANT_ID, DB connections, secrets           │
  │   Port: 8080 (veya atanan port)                     │
  │   Network: nucleo_tenant_{id}                       │
  │                                                     │
  │ Container start → tenant_server_update(container)   │
  │ output: {"container_id": "...", "port": 8080}       │
  ├─────────────────────────────────────────────────────┤
  │ Step 8: CALLBACK_DEPLOY                             │
  │                                                     │
  │ Docker API → Callback service container:            │
  │   Image: nucleo/callback-service:latest             │
  │   Env: TENANT_ID, routing config                    │
  │   Port: 8081                                        │
  │                                                     │
  │ output: {"container_id": "...", "port": 8081}       │
  ├─────────────────────────────────────────────────────┤
  │ Step 9: FRONTEND_DEPLOY                             │
  │                                                     │
  │ Docker API → Nginx + Vue container:                 │
  │   Image: nucleo/tenant-frontend:latest              │
  │   Env: TENANT_ID, API_URL, domain                   │
  │   Port: 443                                         │
  │   Volumes: SSL certs, nginx.conf                    │
  │   DNS: domain → server IP (manuel veya Route53 API) │
  │                                                     │
  │ output: {"container_id": "...", "domain": "..."}    │
  ├─────────────────────────────────────────────────────┤
  │ Step 10: HEALTH_CHECK                               │
  │                                                     │
  │ Tüm component'leri kontrol et:                      │
  │   - DB Primary: pg_isready -h host -p port          │
  │   - DB Replica: replication lag check               │
  │   - Backend: GET /health → 200                      │
  │   - Callback: GET /health → 200                     │
  │   - Frontend: GET / → 200                           │
  │                                                     │
  │ Retry: 3 deneme, 10sn aralık                        │
  │ output: {"checks": [...], "all_healthy": true}      │
  ├─────────────────────────────────────────────────────┤
  │ Step 11: ACTIVATE                                   │
  │                                                     │
  │ tenant_provision_complete(tenant_id, run_id)         │
  │   → provisioning_status = 'active'                  │
  │   → provisioned_at = now()                          │
  │   → Outbox event: 'tenant_provisioned'              │
  │                                                     │
  │ Bu noktadan sonra tenant runtime olarak aktif.       │
  │ Provider enable, game/payment seed ayrıca yapılır.  │
  └─────────────────────────────────────────────────────┘
```

### Hata & Retry Akışı

```
Herhangi bir adım başarısız olursa:
  1. tenant_provision_step_update(status='failed', error_message)
  2. retry_count < max_retries → otomatik retry (exponential backoff)
  3. retry_count >= max_retries → tenant_provision_fail(tenant_id)
     → provisioning_status = 'failed'
     → BO'ya bildirim (outbox event: 'tenant_provision_failed')

BO'dan "Tekrar Dene":
  → gRPC: ProductionManager.RetryProvisioningStep(tenant_id, step_name)
  → Kaldığı adımdan devam eder (önceki completed adımlar atlanır)
  → Yeni run_id ile veya mevcut run ile devam (konfigürasyon)
```

---

## ADIM 4: ProductionManager gRPC Service

### Servis Tanımı

```
Konum: C:\Projects\Git\ProductionManager
Pattern: CryptoManager ile aynı (.NET 10, gRPC, Dapper)
Core DB bağlantısı: Provisioning state okuma/yazma
```

### gRPC API

```protobuf
service ProductionManager {
  // === Provisioning ===
  rpc ProvisionTenant(ProvisionTenantRequest) returns (ProvisionTenantResponse);
  rpc RetryProvisionStep(RetryStepRequest) returns (RetryStepResponse);
  rpc DeprovisionTenant(DeprovisionTenantRequest) returns (DeprovisionTenantResponse);
  rpc GetProvisioningStatus(ProvisioningStatusRequest) returns (ProvisioningStatusResponse);

  // === Health ===
  rpc CheckTenantHealth(TenantHealthRequest) returns (TenantHealthResponse);
  rpc CheckAllTenantsHealth(Empty) returns (AllTenantsHealthResponse);

  // === Template Management ===
  rpc CreateTemplateDump(CreateDumpRequest) returns (CreateDumpResponse);
  rpc ListTemplateDumps(ListDumpsRequest) returns (ListDumpsResponse);
}
```

### Health Check Loop (Background)

```
Her 60 saniyede:
  1. core.tenant_servers WHERE status = 'running' listele
  2. Her container için health check:
     - DB: pg_isready
     - Backend/Callback: HTTP GET /health
     - Frontend: HTTP GET /
  3. Sonuçları güncelle:
     - tenant_server_update(health_status, last_health_at)
  4. Alert koşulları:
     - Container unhealthy → Outbox event: 'tenant_health_alert'
     - Disk usage > 85% → Alert
     - RAM usage > 90% → Alert
     - DB replication lag > 30s → Alert
```

---

## ADIM 5: Template Dump Yönetimi

### Template Dump Oluşturma

```
ProductionManager.CreateTemplateDump() akışı:

1. Template DB'lere (tenant, tenant_audit, ...) deploy scriptlerini çalıştır
   → En güncel şema garanti
2. pg_dump -Fc tenant > tenant_2026.02.12-001.dump
3. Her 5 DB için ayrı dump
4. S3'e yükle (veya shared volume)
5. core.template_dumps'a kayıt ekle

Tetikleme:
  - Manuel: BO'dan "Template Güncelle" butonu
  - CI/CD: deploy_tenant.sql değişikliğinde otomatik
  - Periyodik: Haftada 1 (güvenlik için)
```

### Restore Akışı (Provisioning Step 4)

```
1. core.template_dumps WHERE db_type = 'tenant' AND status = 'active'
   ORDER BY created_at DESC LIMIT 1
2. Dump'ı indir (S3 veya shared path)
3. createdb tenant_{id}
4. pg_restore -d tenant_{id} --no-owner --no-privileges < tenant.dump
5. Grant privileges: nucleo_tenant_{id}
6. Tekrarla: tenant_audit, tenant_log, tenant_report, tenant_affiliate
```

---

## ADIM 6: Deploy Güncellemeleri

### deploy_core.sql eklemeleri:

```sql
-- TABLOLAR (core configuration section, tenant_settings sonrası)
\i core/tables/core/configuration/infrastructure_servers.sql
\i core/tables/core/configuration/tenant_servers.sql
\i core/tables/core/configuration/tenant_provisioning_log.sql
\i core/tables/core/configuration/template_dumps.sql

-- CONSTRAINTS
-- infrastructure_servers, tenant_servers, provisioning_log FK/UQ

-- INDEXES
-- infrastructure_servers, tenant_servers, provisioning_log indexleri

-- FUNCTIONS - Infrastructure
\i core/functions/core/infrastructure/infrastructure_server_create.sql
\i core/functions/core/infrastructure/infrastructure_server_update.sql
\i core/functions/core/infrastructure/infrastructure_server_get.sql
\i core/functions/core/infrastructure/infrastructure_server_list.sql

-- FUNCTIONS - Tenant Servers
\i core/functions/core/tenant_servers/tenant_server_assign.sql
\i core/functions/core/tenant_servers/tenant_server_update.sql
\i core/functions/core/tenant_servers/tenant_server_list.sql

-- FUNCTIONS - Provisioning
\i core/functions/core/provisioning/tenant_provision_start.sql
\i core/functions/core/provisioning/tenant_provision_step_update.sql
\i core/functions/core/provisioning/tenant_provision_complete.sql
\i core/functions/core/provisioning/tenant_provision_fail.sql
\i core/functions/core/provisioning/tenant_provision_status.sql
\i core/functions/core/provisioning/tenant_config_auto_populate.sql
\i core/functions/core/provisioning/tenant_secrets_generate.sql
```

---

## Uygulama Sırası

1. `core.tenants` tablosuna yeni alanlar (1A)
2. Yeni tablolar oluştur (1B-1E)
3. Constraint ve index güncellemeleri (1F)
4. Infrastructure server fonksiyonları (Grup A: 4)
5. Tenant server fonksiyonları (Grup B: 3)
6. Provisioning fonksiyonları (Grup C: 5)
7. Config auto-populate fonksiyonları (Grup D: 2)
8. Deploy dosyaları güncelle
9. ProductionManager servisi oluştur (ayrı repo)

## Doğrulama

- Her fonksiyonun DROP + CREATE syntax kontrolü
- Deploy script sırasının tutarlılığı
- Provisioning state machine geçiş doğrulaması (draft→provisioning→active/failed)
- Health check endpoint erişilebilirlik testi
- Template dump oluşturma ve restore süreci E2E test
- Retry/rollback akışı testi (her adım için failure simulation)

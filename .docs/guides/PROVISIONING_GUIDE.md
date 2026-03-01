> **KULLANIM DIŞI:** Bu rehber artık güncel değildir.
> Fonksiyonel spesifikasyon için bkz. [SPEC_PLATFORM_OPERATIONS.md](SPEC_PLATFORM_OPERATIONS.md).
> Bu dosya yalnızca ek referans olarak korunmaktadır.

# Whitelabel Provisioning — Geliştirici Rehberi

Yeni whitelabel (client) açılışından canlıya alınmasına kadar tam provisioning yaşam döngüsü. **ProductionManager** gRPC servisi bu süreci orchestrate eder.

---

## Büyük Resim

```mermaid
flowchart TD
    BO["BO Admin<br/>1. Company oluştur<br/>2. Client oluştur (draft)<br/>3. Ayarları gir<br/>4. Canlıya Al"]
    BE["Backend (.NET)"]
    PM["ProductionManager Service<br/>(11 adım)"]
    HS["Hedef Sunucu<br/>PostgreSQL (3x) · Backend · Callback · Frontend"]
    BO --> BE -- "gRPC" --> PM --> HS
```

---

## Client Yaşam Döngüsü

```mermaid
flowchart LR
    draft --> pending --> provisioning --> active
    provisioning --> failed
    active --> suspended --> decommissioned
```

| Durum | Açıklama |
|-------|----------|
| `draft` | Client kaydı yapıldı, ayarlar giriliyor |
| `pending` | "Canlıya Al" tıklandı, kuyrukta bekliyor |
| `provisioning` | ProductionManager adımları çalıştırıyor |
| `active` | Tüm health check'ler geçti, client canlı |
| `failed` | Bir adımda hata oluştu (retry edilebilir) |
| `suspended` | Admin tarafından geçici kapatma |
| `decommissioned` | Kalıcı kapatma (login engellenir) |

**Not:** `user_authenticate` fonksiyonunda `provisioning_status != 'decommissioned'` filtresi var. Draft, pending ve provisioning durumundaki client'lara erişim açıktır.

---

## 11 Provisioning Adımı

| # | Adım | Açıklama | Retry |
|---|------|----------|-------|
| 1 | `VALIDATE` | Konfigürasyon kontrol, sunucu erişim testi | 3 |
| 2 | `DB_PROVISION` | PostgreSQL container oluştur (dedicated) veya user oluştur (shared) | 3 |
| 3 | `DB_CREATE` | Client birleşik veritabanı oluştur | 3 |
| 4 | `DB_MIGRATE` | Template dump'tan `pg_restore` | 3 |
| 5 | `DB_SEED` | transaction_types, operation_types, ilk partition'lar | 3 |
| 6 | `WRITE_CONFIG` | DB connection string, secrets, routing | 3 |
| 7 | `BACKEND_DEPLOY` | Backend container deploy | 3 |
| 8 | `CALLBACK_DEPLOY` | Callback service container deploy | 3 |
| 9 | `FRONTEND_DEPLOY` | Nginx + Vue container deploy | 3 |
| 10 | `HEALTH_CHECK` | Tüm component'leri kontrol (`pg_isready` + HTTP `/health`) | 3 |
| 11 | `ACTIVATE` | `provisioning_status = 'active'`, `provisioned_at = NOW()` | 1 |

### Hata Durumunda

- Adım başarısız → `retry_count` artırılır, `max_retries`'a kadar tekrarlanır
- Max retry aşılırsa → `provisioning_status = 'failed'`, `provisioning_step = başarısız adım`
- Admin retry tetikleyebilir: `client_provision_update_step` ile kaldığı yerden devam

---

## Her Client İçin Oluşturulan DB

| # | Veritabanı | Açıklama |
|---|-----------|----------|
| 1 | `client_{id}` | Birleşik DB — 30 schema: iş verileri, log, audit, report, affiliate |

---

## Hosting Modları

`core.clients.hosting_mode` kolonu:

| Mod | Açıklama |
|-----|----------|
| `dedicated` | Client'a özel PostgreSQL container (yüksek trafik) |
| `shared` | Paylaşımlı PostgreSQL instance'da ayrı DB'ler (düşük trafik) |

---

## Template Dump Sistemi

Yeni client DB'leri sıfırdan `deploy_*.sql` çalıştırmak yerine **template dump'tan restore** edilir (çok daha hızlı).

```mermaid
flowchart TD
    T["Template Client (referans)"] -- "pg_dump -Fc" --> S3["S3: so-dumps/client/2026.02.12-001.dump"]
    S3 -- "pg_restore -Fc" --> N["Yeni Client DB: client_42"]
```

### `core.template_dumps` Tablosu

Her DB tipi için ayrı dump kaydı tutulur:

| Kolon | Açıklama |
|-------|----------|
| `db_type` | client (birleşik) |
| `version` | Versiyon etiketi: `2026.02.12-001` |
| `dump_path` | S3 konumu |
| `schema_hash` | Deploy script SHA256 (değişiklik tespiti) |
| `status` | active, deprecated, failed |

---

## Sunucu Yönetimi

### Infrastructure Sunucuları (`core.infrastructure_servers`)

Fiziksel/sanal sunucu envanteri. ProductionManager'ın hedef makineleri.

| Kolon | Açıklama |
|-------|----------|
| `server_name` | Sunucu adı |
| `server_type` | database, application, mixed |
| `region` | eu-west-1, tr-istanbul |
| `max_clients` | Kapasite limiti |
| `current_client_count` | Mevcut client sayısı |
| `health_status` | healthy, unhealthy, maintenance |

### Client Sunucu Atamaları (`core.client_servers`)

Her client component'inin hangi sunucuda çalıştığını tanımlar.

| Kolon | Açıklama |
|-------|----------|
| `server_role` | db_primary, db_replica, db_failover, backend, callback, frontend |
| `container_id` | Docker container ID (provisioning sonrası yazılır) |
| `container_name` | ör: `so_client_42_db_primary` |
| `container_image` | ör: `postgres:16`, `so/client-backend:latest` |
| `status` | pending, creating, running, stopped, error, removed |
| `health_status` | healthy, unhealthy, unknown |
| `health_endpoint` | ör: `http://10.0.1.5:8080/health` |

---

## Health Check

ProductionManager her **60 saniyede** tüm client component'lerini kontrol eder:

| Component | Kontrol Yöntemi |
|-----------|----------------|
| DB Primary | `pg_isready -h host -p port` |
| DB Replica | `pg_isready` + replication lag kontrolü |
| Backend | `HTTP GET /health` → 200 OK |
| Callback | `HTTP GET /health` → 200 OK |
| Frontend | `HTTP GET /` → 200 OK |

Sonuç `core.client_servers.health_status` ve `last_health_at` kolonlarına yazılır.

---

## Provisioning Log

`core.client_provisioning_log` tablosu her adımı ayrıntılı takip eder:

```
provision_run_id: UUID (aynı denemenin tüm adımları)
step_name: VALIDATE, DB_PROVISION, ...
step_order: 1, 2, 3, ...
status: pending → running → completed/failed
duration_ms: adım süresi
error_message/error_detail: hata bilgisi
output: JSONB (adım-spesifik çıktılar)
retry_count: deneme sayısı
```

---

## Decommission (Client Kapatma)

```mermaid
flowchart TD
    BO["BO Admin → Client Kapat"] --> S1
    S1["1. client_decommission_start()<br/>status = decommissioned"]
    S1 --> S2["2. ProductionManager<br/>Container durdur → DB backup → Container sil"]
    S2 --> S3["3. client_decommission_complete()<br/>log kaydı"]
```

**Decommission sonrası:**
- `user_authenticate` fonksiyonu bu client'ı filtreler → hiçbir kullanıcı login olamaz
- DB verileri backup'ta korunur (regülasyon gereği)
- Container kaynakları serbest kalır

---

## DB Yapısı Özeti

| Tablo | Şema | Açıklama |
|-------|------|----------|
| `clients` | core | Client kaydı + provisioning durum/adım |
| `infrastructure_servers` | core | Fiziksel sunucu envanteri |
| `client_servers` | core | Client-sunucu atamaları + container bilgileri |
| `template_dumps` | core | Template DB dump versiyonları |
| `client_provisioning_log` | core | Adım adım provisioning takibi |

---

## Fonksiyon Listesi

### Provisioning Orchestration (4 fonksiyon)

| Fonksiyon | Açıklama |
|----------|----------|
| `client_provision_start` | Provisioning başlat (status → provisioning) |
| `client_provision_update_step` | Adım ilerlet/güncelle |
| `client_provision_complete` | Başarılı tamamla (status → active) |
| `client_provision_fail` | Hata kaydet (status → failed) |

### Decommission (3 fonksiyon)

| Fonksiyon | Açıklama |
|----------|----------|
| `client_decommission_start` | Kapatma başlat (status → decommissioned) |
| `client_decommission_complete` | Kapatma tamamla + log |
| `client_provision_history_list` | Provisioning geçmişi listesi |

### Infrastructure (4 fonksiyon)

| Fonksiyon | Açıklama |
|----------|----------|
| `infrastructure_server_create` | Sunucu kaydı oluştur |
| `infrastructure_server_update` | Sunucu bilgisi güncelle |
| `infrastructure_server_get` | Sunucu detayı |
| `infrastructure_server_list` | Sunucu listesi + kapasite |

### Client Server (2 mevcut)

| Fonksiyon | Açıklama |
|----------|----------|
| `client_server_update` | Sunucu ataması güncelle |
| `client_server_list` | Client sunucu listesi |

> **Not:** `client_server_create`, `client_server_health_update` ve 3 template fonksiyonu henüz yazılmadı (ProductionManager bağımlılığı).

---

## ProductionManager gRPC API (Ayrı Repo)

```protobuf
service ProductionManager {
    rpc ProvisionClient(ProvisionRequest) returns (ProvisionResponse);
    rpc RetryProvisionStep(RetryRequest) returns (StepResponse);
    rpc DeprovisionClient(DeprovisionRequest) returns (DeprovisionResponse);
    rpc GetProvisioningStatus(StatusRequest) returns (StatusResponse);
    rpc CheckClientHealth(HealthRequest) returns (HealthResponse);
    rpc CreateTemplateDump(DumpRequest) returns (DumpResponse);
}
```

Pattern: CryptoManager gRPC servisi ile aynı mimari (`C:\Projects\Git\CryptoManager`).

---

## Backend İçin Notlar

- **Client seeding backend üzerinden yapılır** — Core DB'de client kaydı + Client DB'lerde seed data ayrı connection'lar
- **DB_SEED adımı**: `transaction_types`, `operation_types` ve ilk partition'lar her yeni client'a eklenir
- **Config auto-populate**: Connection string'ler, API key'ler ve secret'lar otomatik oluşturulur
- **Domain yönetimi**: `core.clients.domain` ve `subdomain` alanları DNS routing için kullanılır
- **Retry**: Her adım bağımsız retry edilebilir, kaldığı yerden devam eder

---

_İlgili dokümanlar: [PROVISIONING_ARCHITECTURE.md](../../.planning/PROVISIONING_ARCHITECTURE.md) · [FUNCTIONS_CORE.md](../reference/FUNCTIONS_CORE.md) · [DATABASE_ARCHITECTURE.md](../reference/DATABASE_ARCHITECTURE.md)_

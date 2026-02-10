# NUCLEO – PARTITION MİMARİSİ

Bu doküman, Nucleo platformundaki tüm partitioned tabloların yapısını, yönetim fonksiyonlarını ve operasyonel kullanımını açıklar.

---

## 1. Genel Yaklaşım

### 1.1 Inline Tanım

Partitioned tablolar **kendi tablo dosyasında** tanımlıdır. Ayrı bir `partitions/` klasörü veya dosyası **yoktur**.

Her partitioned tablo dosyasında:

```sql
CREATE TABLE schema.table_name (
    id          bigserial,
    ...
    created_at  timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (id, created_at)        -- Composite PK (partition key dahil)
) PARTITION BY RANGE (created_at);

CREATE TABLE schema.table_name_default PARTITION OF schema.table_name DEFAULT;
```

### 1.2 Temel Kurallar

| Kural | Açıklama |
|-------|----------|
| **Composite PK** | Partitioned tablolarda PK, partition key'i içermelidir: `PRIMARY KEY (id, partition_key)` |
| **Default Partition** | Her tabloda `_default` partition bulunur. Hiçbir range'e uymayan veri buraya düşer |
| **FK Kısıtlaması** | Partitioned tabloya **referans veren** FK'lar çalışmaz (composite PK nedeniyle). Application-level bütünlük kullanılır |
| **FK'dan çıkan** | Partitioned tablodan regular tabloya FK sorunsuz çalışır |
| **Range tipi** | `[start, end)` — sol dahil, sağ hariç |

### 1.3 Partition Stratejileri

| Strateji | Partition Tipi | Kullanım | Oluşturma Aralığı |
|----------|---------------|----------|-------------------|
| **Daily** | `PARTITION BY RANGE (timestamptz)` | Log veritabanları (kısa retention) | Bugün + 7 gün ileri |
| **Monthly** | `PARTITION BY RANGE (timestamptz/date)` | İş verileri ve raporlar (sınırsız retention) | Bu ay + 3 ay ileri |

### 1.4 Partition İsimlendirme

| Tip | Format | Örnek |
|-----|--------|-------|
| Daily | `{tablo}_y{YYYY}m{MM}d{DD}` | `error_logs_y2026m02d06` |
| Monthly | `{tablo}_y{YYYY}m{MM}` | `transactions_y2026m02` |
| Default | `{tablo}_default` | `transactions_default` |

---

## 2. Partitioned Tablolar

### 2.1 Özet Matris

| DB | Strateji | Tablo Sayısı | Retention |
|----|----------|-------------|-----------|
| `core` | Monthly | 2 | 90–180 gün |
| `core_audit` | Daily | 1 | 90 gün |
| `core_log` | Daily | 4 | 30–90 gün |
| `tenant` | Monthly | 2 | Sınırsız* |
| `tenant_log` | Daily | 5 | 30–90 gün |
| `tenant_report` | Monthly | 5 | Sınırsız |
| `core_report` | Monthly | 5 | Sınırsız |
| `tenant_affiliate` | Monthly | 7 | Sınırsız |
| `tenant_audit` | Hybrid (Daily+Monthly) | 2 | 365 gün / 5 yıl |
| **Toplam** | | **33** | |

> \* `core` Monthly: `messaging.user_messages` (180 gün) + `security.user_sessions` (90 gün).
> \* `tenant` Monthly: `transaction.transactions` (sınırsız) + `messaging.player_messages` (180 gün).

### 2.2 core_audit (Daily, 90 gün retention)

| Tablo | Partition Key | Retention | Dosya |
|-------|--------------|-----------|-------|
| `backoffice.auth_audit_log` | `created_at` | 90 gün | `core_audit/tables/backoffice/auth_audit_log.sql` |

> **Not:** Backoffice kullanıcı güvenlik olay kayıtları (login, logout, şifre değişikliği). GeoIP verileri ile zenginleştirilmiş. Yüksek hacim nedeniyle daily partition tercih edildi.

### 2.3 core (Monthly, 90–180 gün retention)

| Tablo | Partition Key | Retention | Dosya |
|-------|--------------|-----------|-------|
| `messaging.user_messages` | `created_at` | 180 gün | `core/tables/messaging/user_messages.sql` |
| `security.user_sessions` | `created_at` | 90 gün | `core/tables/security/user_sessions.sql` |

> **Not:** Backoffice kullanıcı mesajlaşma sistemi ve oturum yönetimi. `user_sessions` UPDATE-then-INSERT pattern ile çalışır, GeoIP verileri ile zenginleştirilmiştir.

### 2.4 core_log (Daily, 30–90 gün retention)

| Tablo | Partition Key | Dosya |
|-------|--------------|-------|
| `logs.error_logs` | `occurred_at` | `core_log/tables/logs/error_logs.sql` |
| `logs.audit_logs` | `created_at` | `core_log/tables/logs/audit_logs.sql` |
| `logs.dead_letter_messages` | `created_at` | `core_log/tables/logs/dead_letter_messages.sql` |
| `backoffice.audit_logs` | `created_at` | `core_log/tables/backoffice/audit_logs.sql` |

### 2.5 tenant_log (Daily, 30–90 gün retention)

| Tablo | Partition Key | Dosya |
|-------|--------------|-------|
| `affiliate_log.api_requests` | `created_at` | `tenant_log/tables/affiliate/api_requests.sql` |
| `affiliate_log.commission_calculations` | `created_at` | `tenant_log/tables/affiliate/commission_calculations.sql` |
| `affiliate_log.report_generations` | `created_at` | `tenant_log/tables/affiliate/report_generations.sql` |
| `kyc_log.player_kyc_provider_logs` | `created_at` | `tenant_log/tables/kyc/player_kyc_provider_logs.sql` |
| `messaging_log.message_delivery_logs` | `created_at` | `tenant_log/tables/messaging/message_delivery_logs.sql` |

### 2.6 tenant_report (Monthly, sınırsız retention)

| Tablo | Partition Key | Dosya |
|-------|--------------|-------|
| `finance.player_hourly_stats` | `period_hour` | `tenant_report/tables/finance/player_hourly_stats.sql` |
| `finance.transaction_hourly_stats` | `period_hour` | `tenant_report/tables/finance/transaction_hourly_stats.sql` |
| `finance.system_hourly_kpi` | `period_hour` | `tenant_report/tables/finance/system_hourly_kpi.sql` |
| `game.game_hourly_stats` | `period_hour` | `tenant_report/tables/game/game_hourly_stats.sql` |
| `game.game_performance_daily` | `report_date` | `tenant_report/tables/game/game_performance_daily.sql` |

### 2.7 core_report (Monthly, sınırsız retention)

| Tablo | Partition Key | Dosya |
|-------|--------------|-------|
| `finance.tenant_daily_kpi` | `report_date` | `core_report/tables/finance/tenant_daily_kpi.sql` |
| `billing.monthly_invoices` | `created_at` | `core_report/tables/billing/monthly_invoices.sql` |
| `performance.tenant_traffic_hourly` | `period_hour` | `core_report/tables/performance/tenant_traffic_hourly.sql` |
| `performance.provider_global_daily` | `report_date` | `core_report/tables/performance/provider_global_daily.sql` |
| `performance.payment_global_daily` | `report_date` | `core_report/tables/performance/payment_global_daily.sql` |

### 2.8 tenant (Monthly, karma retention)

| Tablo | Partition Key | Retention | Dosya |
|-------|--------------|-----------|-------|
| `transaction.transactions` | `created_at` | Sınırsız | `tenant/tables/transaction/transactions.sql` |
| `messaging.player_messages` | `created_at` | 180 gün | `tenant/tables/messaging/player_messages.sql` |

> **FK Etkisi (transactions):** `transactions` tablosunun PK'sı `(id, created_at)` olduğundan, `transaction_workflows.transaction_id → transactions(id)` ve `transactions.related_transaction_id → transactions(id)` (self-reference) FK'ları kaldırılmıştır. Bütünlük application-level'da sağlanır. Değişiklik: `tenant/constraints/transaction.sql`
>
> **FK Etkisi (player_messages):** `player_messages` tablosunun PK'sı `(id, created_at)` olduğundan composite PK'dır. `campaign_id → message_campaigns(id)` FK'sı partitioned'dan regular tabloya gittiği için sorunsuz çalışır (PG 12+).

### 2.9 tenant_affiliate (Monthly, sınırsız retention)

| Tablo | Partition Key | Dosya |
|-------|--------------|-------|
| `tracking.link_clicks` | `clicked_at` | `tenant_affiliate/tables/tracking/link_clicks.sql` |
| `tracking.transaction_events` | `created_at` | `tenant_affiliate/tables/tracking/transaction_events.sql` |
| `tracking.player_game_stats_daily` | `game_date` | `tenant_affiliate/tables/tracking/player_game_stats_daily.sql` |
| `tracking.player_finance_stats_daily` | `stats_date` | `tenant_affiliate/tables/tracking/player_finance_stats_daily.sql` |
| `tracking.affiliate_stats_daily` | `stats_date` | `tenant_affiliate/tables/tracking/affiliate_stats_daily.sql` |
| `tracking.player_stats_monthly` | `(period_year, period_month)` | `tenant_affiliate/tables/tracking/player_stats_monthly.sql` |
| `tracking.affiliate_stats_monthly` | `(period_year, period_month)` | `tenant_affiliate/tables/tracking/affiliate_stats_monthly.sql` |

> **Multi-column Range:** `player_stats_monthly` ve `affiliate_stats_monthly` tabloları tek bir tarih kolonu olmadığından `PARTITION BY RANGE (period_year, period_month)` kullanır.

### 2.10 tenant_audit (Hybrid: Daily + Monthly)

| Tablo | Partition Tipi | Partition Key | Retention | Dosya |
|-------|---------------|--------------|-----------|-------|
| `player_audit.login_attempts` | Daily | `attempted_at` | 365 gün | `tenant_audit/tables/player_audit/login_attempts.sql` |
| `player_audit.login_sessions` | Monthly | `created_at` | 1825 gün (5 yıl) | `tenant_audit/tables/player_audit/login_sessions.sql` |

> **Hybrid partition:** tenant_audit, tek DB'de hem daily hem monthly partition stratejisi barındıran ilk veritabanıdır. `create_partitions()` fonksiyonu her iki stratejiyi ayrı parametrelerle yönetir (`p_look_ahead_days` + `p_look_ahead_months`).
> Diğer tenant_audit tabloları (`affiliate_audit`, `kyc_audit`) partitioned **değildir** (düşük hacim, long retention).

### 2.11 Partition Uygulanmayan Veritabanları

| DB | Sebep |
|----|-------|
| `bonus` | Konfigürasyon verileri, düşük hacim |
| `game`, `finance`, `game_log`, `finance_log` | Henüz tablo oluşturulmadı |

---

## 3. Yönetim Fonksiyonları

Her partitioned veritabanı `maintenance` şemasında 4 fonksiyon içerir.

**Dosya konumu:** `{db}/functions/maintenance/`

### 3.1 create_partitions(p_look_ahead)

Gelecek partition'ları otomatik oluşturur.

```sql
SELECT * FROM maintenance.create_partitions();        -- Varsayılan look-ahead
SELECT * FROM maintenance.create_partitions(6);       -- 6 ay/gün ileri
```

| Parametre | Varsayılan | Açıklama |
|-----------|-----------|----------|
| `p_look_ahead_months` (monthly) | 3 | Bu ay + N ay ileri |
| `p_look_ahead_days` (daily) | 7 | Bugün + N gün ileri |

**Davranış:**
- `pg_class` kataloğunda partition'ın varlığını kontrol eder
- Yoksa `CREATE TABLE ... PARTITION OF ... FOR VALUES FROM (...) TO (...)` çalıştırır
- Varsa atlar (`IDEMPOTENT`)
- Her satır için `CREATED` veya `EXISTS` action döner

**Örnek çıktı** (bugün: 2026-02-06):

| table_name | partition_name | range_start | range_end | action |
|---|---|---|---|---|
| transaction.transactions | transaction.transactions_y2026m02 | 2026-02-01 | 2026-03-01 | CREATED |
| transaction.transactions | transaction.transactions_y2026m03 | 2026-03-01 | 2026-04-01 | CREATED |
| transaction.transactions | transaction.transactions_y2026m04 | 2026-04-01 | 2026-05-01 | CREATED |
| transaction.transactions | transaction.transactions_y2026m05 | 2026-05-01 | 2026-06-01 | CREATED |

### 3.2 drop_expired_partitions(p_retention_days)

Süresi dolan partition'ları siler.

```sql
SELECT * FROM maintenance.drop_expired_partitions(90);    -- 90 günden eski partition'ları sil
SELECT * FROM maintenance.drop_expired_partitions();       -- Varsayılan retention (DB'ye göre değişir)
```

| Parametre | Varsayılan | Açıklama |
|-----------|-----------|----------|
| `p_retention_days` (log DB'ler) | 90 | Gün cinsinden retention süresi |
| `p_retention_days` (iş DB'leri) | 36500 (~100 yıl) | Fiilen sınırsız retention |

**Güvenlik kuralları:**
- Aktif ayın/günün partition'ını **ASLA silmez**
- Default partition'ı **ASLA silmez** (`_default` isimli olanlar filtrelenir)
- Partition isminden tarihi regex ile çıkarır (`_yYYYYmMM` veya `_yYYYYmMMdDD`)
- Parse edilemeyen isimler atlanır (hata vermez)

### 3.3 partition_info()

Mevcut partition durumunu raporlar. Monitoring ve health check için kullanılır.

```sql
SELECT * FROM maintenance.partition_info();
```

**Örnek çıktı:**

| parent_table | partition_count | oldest_partition | newest_partition | total_size | default_partition_size |
|---|---|---|---|---|---|
| transaction.transactions | 4 | transactions_y2026m02 | transactions_y2026m05 | 64 kB | 0 bytes |

**Alarm durumu:** `default_partition_size > 0` ise veri yanlış yere düşüyor demektir. Ya partition eksik, ya da beklenmeyen tarihli veri gelmiştir.

### 3.4 run_maintenance(p_retention_days, p_look_ahead)

Cron job için ana fonksiyon. `create_partitions()` + `drop_expired_partitions()` çağırır.

```sql
SELECT * FROM maintenance.run_maintenance();              -- Varsayılan parametreler
SELECT * FROM maintenance.run_maintenance(90, 7);         -- Log DB: 90 gün retention, 7 gün ileri
SELECT * FROM maintenance.run_maintenance(36500, 3);      -- İş DB: sınırsız retention, 3 ay ileri
```

---

## 4. Deploy Akışı

### 4.1 Deploy Script Sıralaması

Her deploy script'te (`deploy_{db}.sql`) şu sıra izlenir:

```
1. Schemas          → CREATE SCHEMA IF NOT EXISTS ...
2. Extensions       → CREATE EXTENSION IF NOT EXISTS ...
3. Tables           → \i {db}/tables/...           (partition tanımı + default partition dahil)
4. Views            → \i {db}/views/...            (varsa)
5. Constraints      → \i {db}/constraints/...      (FK'lar)
6. Functions        → \i {db}/functions/...         (maintenance dahil)
7. Indexes          → \i {db}/indexes/...
8. Initial Setup    → SELECT * FROM maintenance.create_partitions();
```

### 4.2 İlk Deploy Sonrası Durum

**`deploy_core.sql` çalıştırıldıktan sonra:**

```
messaging.user_messages                   -- Ana partitioned tablo (180 gün retention)
├── messaging.user_messages_y2026m02      -- Şubat 2026
├── messaging.user_messages_y2026m03      -- Mart 2026
├── messaging.user_messages_y2026m04      -- Nisan 2026
├── messaging.user_messages_y2026m05      -- Mayıs 2026
└── messaging.user_messages_default       -- Güvenlik ağı

security.user_sessions                    -- Ana partitioned tablo (90 gün retention)
├── security.user_sessions_y2026m02       -- Şubat 2026
├── security.user_sessions_y2026m03       -- Mart 2026
├── security.user_sessions_y2026m04       -- Nisan 2026
├── security.user_sessions_y2026m05       -- Mayıs 2026
└── security.user_sessions_default        -- Güvenlik ağı
```

**`deploy_tenant.sql` çalıştırıldıktan sonra:**

```
transaction.transactions                  -- Ana partitioned tablo (sınırsız retention)
├── transaction.transactions_y2026m02     -- Şubat 2026
├── transaction.transactions_y2026m03     -- Mart 2026
├── transaction.transactions_y2026m04     -- Nisan 2026
├── transaction.transactions_y2026m05     -- Mayıs 2026
└── transaction.transactions_default      -- Güvenlik ağı

messaging.player_messages                 -- Ana partitioned tablo (180 gün retention)
├── messaging.player_messages_y2026m02    -- Şubat 2026
├── messaging.player_messages_y2026m03    -- Mart 2026
├── messaging.player_messages_y2026m04    -- Nisan 2026
├── messaging.player_messages_y2026m05    -- Mayıs 2026
└── messaging.player_messages_default     -- Güvenlik ağı
```

---

## 5. Operasyonel Kullanım

### 5.1 Geliştirme Ortamı (Dev)

**Maintenance script'leri çalıştırılmasa da çalışır.** Default partition tüm veriyi yakalar. Partition pruning (performans optimizasyonu) olmaz ama dev'de bu önemsizdir.

Deploy script'in sonundaki `SELECT * FROM maintenance.create_partitions();` opsiyoneldir - çalışsa da zararsız, çalışmasa da veri kaybı olmaz.

### 5.2 Staging / Production

Düzenli `run_maintenance()` çağrısı **zorunludur**. Aksi halde look-ahead süresi dolunca yeni partition oluşmaz ve veri default'a düşer.

#### pg_cron ile (PostgreSQL Extension)

```sql
-- Daily partition DB'leri: Her gün 02:00
SELECT cron.schedule('core-log-maintenance',
    '0 2 * * *',
    $$SELECT * FROM maintenance.run_maintenance(90, 7)$$
);

-- Monthly partition DB'leri: Her hafta Pazartesi 03:00
SELECT cron.schedule('tenant-maintenance',
    '0 3 * * 1',
    $$SELECT * FROM maintenance.run_maintenance()$$
);
```

#### OS Crontab ile

```bash
# Daily partition DB'leri - Her gün 02:00
0 2 * * * psql -d core_audit -c "SELECT * FROM maintenance.run_maintenance(90, 7);"
0 2 * * * psql -d core_log -c "SELECT * FROM maintenance.run_maintenance(90, 7);"
0 2 * * * psql -d tenant_001_log -c "SELECT * FROM maintenance.run_maintenance(90, 7);"

# Monthly partition DB'leri - Her hafta Pazartesi 03:00
0 3 * * 1 psql -d core -c "SELECT * FROM maintenance.run_maintenance();"
0 3 * * 1 psql -d tenant_001 -c "SELECT * FROM maintenance.run_maintenance();"
0 3 * * 1 psql -d tenant_001_report -c "SELECT * FROM maintenance.run_maintenance();"
0 3 * * 1 psql -d tenant_001_affiliate -c "SELECT * FROM maintenance.run_maintenance();"
0 3 * * 1 psql -d core_report -c "SELECT * FROM maintenance.run_maintenance();"
```

#### Backend Application ile (Önerilen)

Backend scheduled job/worker üzerinden:
1. Her tenant DB'ye ayrı connection aç
2. `SELECT * FROM maintenance.run_maintenance(...)` çağır
3. Sonuçları logla
4. `default_partition_size > 0` ise alert gönder

### 5.3 Önerilen Cron Takvimi

| DB | Partition Tipi | Sıklık | Retention Param | Look-ahead Param |
|----|---------------|--------|-----------------|------------------|
| `core` | Monthly | Haftada 1 | 180 | 3 |
| `core_audit` | Daily | Her gün | 90 | 7 |
| `core_log` | Daily | Her gün | 90 | 7 |
| `tenant_log` | Daily | Her gün | 90 | 7 |
| `tenant_report` | Monthly | Haftada 1 | 36500 (sınırsız) | 3 |
| `core_report` | Monthly | Haftada 1 | 36500 (sınırsız) | 3 |
| `tenant_affiliate` | Monthly | Haftada 1 | 36500 (sınırsız) | 3 |
| `tenant` | Monthly | Haftada 1 | 36500 (sınırsız) | 3 |
| `tenant_audit` | Hybrid | Her gün | 365 (daily) / 1825 (monthly) | 7 gün / 3 ay |

### 5.4 Monitoring Sorguları

```sql
-- Partition durumu kontrolü
SELECT * FROM maintenance.partition_info();

-- Default partition'a düşen veri var mı? (ALARM)
SELECT * FROM maintenance.partition_info()
WHERE default_partition_size != '0 bytes';

-- Gelecek partition'lar yeterli mi?
SELECT * FROM maintenance.create_partitions()
WHERE action = 'CREATED';  -- Boş dönerse her şey hazır
```

---

## 6. PostgreSQL Partition Pruning

Partition pruning, PostgreSQL'in sorgu optimizasyonudur. WHERE koşulunda partition key kullanıldığında sadece ilgili partition taranır.

```sql
-- HIZLI: Sadece Şubat 2026 partition'ı taranır
SELECT * FROM transaction.transactions
WHERE created_at >= '2026-02-01' AND created_at < '2026-03-01';

-- YAVAŞ: Tüm partition'lar taranır (partition key yok)
SELECT * FROM transaction.transactions
WHERE player_id = 12345;

-- OPTİMAL: Partition pruning + index kullanılır
SELECT * FROM transaction.transactions
WHERE created_at >= '2026-02-01' AND created_at < '2026-03-01'
  AND player_id = 12345;
```

**Önemli:** `enable_partition_pruning = on` (PostgreSQL varsayılanı) olmalıdır.

---

## 7. Jurisdiction Bazlı Retention Yönetimi

Farklı ülke/lisans otoritelerinin veri saklama süreleri farklıdır (örn. Almanya GwG: 10 yıl, Malta MGA: 5 yıl). Bu nedenle `drop_expired_partitions` fonksiyonu her tenant için farklı parametrelerle çağrılmalıdır.

### 7.1 Mimari Karar

**Retention kuralları merkezi olarak Core DB'de tutulur.** Tenant DB'lerde ayrı bir config tablosu yoktur.

```
core.catalog.data_retention_policies
├── jurisdiction_id   → FK → catalog.jurisdictions
├── data_category     → 'kyc_data', 'transaction_logs', 'affiliate_logs', 'player_data'...
├── retention_days    → 1825 (5 yıl), 3650 (10 yıl)...
└── legal_reference   → 'GDPR Art.17', 'GwG §8', 'MGA DPA'...
```

### 7.2 Çalışma Akışı

```
Backend Scheduled Job
│
├─ 1. Core DB'den tenant listesini çek (core.tenants + jurisdiction_id)
├─ 2. Core DB'den jurisdiction bazlı retention kurallarını çek
│     SELECT data_category, retention_days
│     FROM catalog.data_retention_policies
│     WHERE jurisdiction_id = :tenant_jurisdiction
│
├─ 3. Her tenant için ilgili DB'lere bağlan ve retention uygula:
│     ├─ tenant_log DB  → run_maintenance(kyc_retention, 7)
│     ├─ tenant DB      → run_maintenance(transaction_retention, 3)
│     └─ tenant_affiliate DB → run_maintenance(affiliate_retention, 3)
│
└─ 4. Sonuçları logla, alert gönder
```

### 7.3 Örnek Retention Süreleri

| Jurisdiction | KYC Data | Transaction Logs | Player Data | Affiliate Logs |
|-------------|----------|-----------------|-------------|---------------|
| MGA (Malta) | 1825 (5 yıl) | 1825 (5 yıl) | 1825 (5 yıl) | 1095 (3 yıl) |
| UKGC (UK) | 2190 (6 yıl) | 2190 (6 yıl) | 2190 (6 yıl) | 1095 (3 yıl) |
| GGL (Almanya) | 3650 (10 yıl) | 3650 (10 yıl) | 3650 (10 yıl) | 1825 (5 yıl) |
| Curaçao | 1825 (5 yıl) | 1095 (3 yıl) | 1095 (3 yıl) | 730 (2 yıl) |

> **Not:** Bu süreler örnektir. Gerçek değerler yasal danışmanlık ile belirlenmelidir.

### 7.4 Neden Tenant DB'de Config Yok?

- **Tek kaynak (single source of truth):** Jurisdiction kuralları değiştiğinde sadece core güncellenir
- **Senkronizasyon gereksiz:** Tenant DB'de kopyası olsa güncelliği garanti edilemez
- **Backend zaten biliyor:** Her tenant'ın jurisdiction'ını çağrı anında core'dan okur
- **Basitlik:** maintenance fonksiyonları parametrik kalır, config bağımlılığı yoktur

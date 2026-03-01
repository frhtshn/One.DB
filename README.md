# OneDB

**Sortis One**, online gaming/betting platformları için tasarlanmış, core-centric mimariye sahip, multi-client (whitelabel) destekli bir orchestration platformunun veritabanı katmanıdır.

| Metrik | Değer |
|--------|-------|
| Veritabanı | 14 |
| Tablo | 279 |
| Fonksiyon | 795 |
| İzin (Permission) | 147 |
| Rol | 8 |

**Teknoloji:** PostgreSQL 16 · .NET 10 · Dapper ORM

---

## Mimari Özet

### Veritabanı Katmanları

| Katman | Veritabanları | Paylaşım |
|--------|---------------|----------|
| **Core** | core, core_log, core_audit, core_report | Tüm clientlar (paylaşımlı) |
| **Gateway** | game, game_log, finance, finance_log | Tüm clientlar (paylaşımlı) |
| **Plugin** | bonus | Tüm clientlar (paylaşımlı) |
| **Client** | client, client_log, client_audit, client_report, client_affiliate | İzole (her client'a özel) |

> **Kritik:** Her klasör ayrı bir fiziksel PostgreSQL veritabanını temsil eder. Veritabanları arası doğrudan sorgu **yapılamaz** — cross-DB iletişim backend (.NET/Dapper) üzerinden yürütülür.

---

## Kurulacak VS Code Extension'ları

1. **SQLTools**  
   Publisher: Matheus Teixeira

2. **SQLTools PostgreSQL/Cockroach Driver**  
   Publisher: Matheus Teixeira

Bu extension'larla db'ye bağlanılır. Daha sonra bir script yazıldığında "Run Script" yapılarak direk deploy alınır.

---

## Dokümantasyon

Detaylı mimari ve yapı dokümantasyonu `.docs/` klasöründedir. Referans dokümanları `.docs/reference/`, geliştirici rehberleri `.docs/guides/` altındadır.

### Referans (Mimari & Fonksiyonlar)

| Dosya                                                                          | Açıklama                                                     |
| ------------------------------------------------------------------------------ | ------------------------------------------------------------ |
| [PROJECT_OVERVIEW.md](.docs/reference/PROJECT_OVERVIEW.md)                     | **Proje genel bakış, sistem mimarisi ve veri akışı**         |
| [DATABASE_ARCHITECTURE.md](.docs/reference/DATABASE_ARCHITECTURE.md)           | Veritabanı mimarisi, şemalar ve tablolar                     |
| [PARTITION_ARCHITECTURE.md](.docs/reference/PARTITION_ARCHITECTURE.md)         | Partition yapısı ve yönetim fonksiyonları                     |
| [LOGSTRATEGY.md](.docs/reference/LOGSTRATEGY.md)                               | Log, audit ve retention stratejisi                           |
| [DATABASE_FUNCTIONS.md](.docs/reference/DATABASE_FUNCTIONS.md)                 | Stored procedure ve trigger referansı (index)                |
| [FUNCTIONS_CORE.md](.docs/reference/FUNCTIONS_CORE.md)                         | Core katmanı fonksiyon ve trigger'ları                       |
| [FUNCTIONS_CLIENT.md](.docs/reference/FUNCTIONS_CLIENT.md)                     | Client katmanı fonksiyon ve trigger'ları                     |
| [FUNCTIONS_GATEWAY.md](.docs/reference/FUNCTIONS_GATEWAY.md)                   | Gateway & plugin (game, finance, bonus) fonksiyonları        |

### Rehberler (Guides)

| Dosya                                                                          | Açıklama                                                     |
| ------------------------------------------------------------------------------ | ------------------------------------------------------------ |
| [GAME_GATEWAY_GUIDE.md](.docs/guides/GAME_GATEWAY_GUIDE.md)                   | Oyun gateway entegrasyonu geliştirme rehberi                 |
| [FINANCE_GATEWAY_GUIDE.md](.docs/guides/FINANCE_GATEWAY_GUIDE.md)             | Finans gateway entegrasyonu geliştirme rehberi               |
| [BONUS_ENGINE_GUIDE.md](.docs/guides/BONUS_ENGINE_GUIDE.md)                   | Bonus motoru (JSON-driven rule engine) rehberi               |
| [PROVISIONING_GUIDE.md](.docs/guides/PROVISIONING_GUIDE.md)                   | Client provisioning/decommission rehberi                     |
| [SHADOW_MODE_GUIDE.md](.docs/guides/SHADOW_MODE_GUIDE.md)                     | Shadow mode (canlı test) rehberi                             |
| [CROSS_DB_JOIN_GUIDE.md](.docs/guides/CROSS_DB_JOIN_GUIDE.md)                 | Cross-DB veri erişim ve join stratejileri                    |
| [CALL_CENTER_GUIDE.md](.docs/guides/CALL_CENTER_GUIDE.md)                     | Çağrı merkezi ve ticket sistemi rehberi                      |
| [PLAYER_AUTH_KYC_GUIDE.md](.docs/guides/PLAYER_AUTH_KYC_GUIDE.md)             | Oyuncu kimlik doğrulama ve KYC rehberi                       |
| [SITE_MANAGEMENT_GUIDE.md](.docs/guides/SITE_MANAGEMENT_GUIDE.md)             | Site yönetimi ve yapılandırma rehberi                        |
| [IMPLEMENTATION_CHANGE_GUIDE.md](.docs/guides/IMPLEMENTATION_CHANGE_GUIDE.md) | Geliştirme değişiklik yönetimi rehberi                       |


---

## Deployment Script (deploy.ps1)

Bu script, yerel geliştirme ortamında veritabanı dağıtımı ve yönetimi için kullanılır.

**Temel Kullanım**

```powershell
# Default: deploy_core.sql -> core database
.\deploy.ps1
```

**Dosya Belirtme**

Belirli bir veritabanını veya senaryoyu deploy etmek için:

```powershell
.\deploy.ps1 deploy_core.sql           # core db
.\deploy.ps1 deploy_core_staging.sql   # core db (staging seed)
.\deploy.ps1 deploy_core_report.sql    # core_report db
.\deploy.ps1 deploy_client.sql         # client db
.\deploy.ps1 deploy_game.sql           # game db
.\deploy.ps1 create_dbs.sql            # postgres db (tüm db'leri oluşturma)
```

**Dry Run (Önce Kontrol)**

Değişiklik yapmadan bağlantıyı test etmek ve yapılacak işlemleri görmek için `-Dry` parametresini kullanın:

```powershell
# Bağlantıyı test et, deploy etme
.\deploy.ps1 deploy_core.sql -Dry
.\deploy.ps1 deploy_client.sql -Dry
```

**Reset (Schema Sil + Deploy)**

Mevcut şemaları silip sıfırdan kurulum yapmak için `-Reset` parametresini kullanın:

```powershell
# Tüm schema'ları sil, sıfırdan kur
.\deploy.ps1 deploy_core.sql -Reset

# Önce kontrol et (Reset modunda ne olacağını gör)
.\deploy.ps1 deploy_core.sql -Reset -Dry
```

**Kombinasyonlar**

Farklı parametreleri birleştirerek kullanabilirsiniz:

```powershell
# Client veritabanını sıfırla ve yeniden kur
.\deploy.ps1 deploy_client.sql -Reset

# Game veritabanı deploy işlemini simüle et (Dry Run)
.\deploy.ps1 deploy_game.sql -Dry

# Production seed ile core veritabanını sıfırdan kur
.\deploy.ps1 deploy_core_production.sql -Reset
```

---

## Beta Server Deployment

```bash
set PGPASSWORD=NucleoPostgres2026
```

### 0. Create Databases

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d postgres -f create_dbs.sql
```

### 1. Deploy Core

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d core -f deploy_core.sql
```

### 2. Deploy Core Audit

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d core_audit -f deploy_core_audit.sql
```

### 3. Deploy Core Log

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d core_log -f deploy_core_log.sql
```

### 4. Deploy Core Report

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d core_report -f deploy_core_report.sql
```

### 5. Deploy Client

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d client -f deploy_client.sql
```

### 6. Deploy Client Affiliate

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d client_affiliate -f deploy_client_affiliate.sql
```

### 7. Deploy Client Audit

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d client_audit -f deploy_client_audit.sql
```

### 8. Deploy Client Log

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d client_log -f deploy_client_log.sql
```

### 9. Deploy Client Report

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d client_report -f deploy_client_report.sql
```

### 10. Deploy Bonus

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d bonus -f deploy_bonus.sql
```

### 11. Deploy Finance

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d finance -f deploy_finance.sql
```

### 12. Deploy Finance Log

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d finance_log -f deploy_finance_log.sql
```

### 13. Deploy Game

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d game -f deploy_game.sql
```

### 14. Deploy Game Log

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d game_log -f deploy_game_log.sql
```

### 15. Master Deploy (Tüm DB'ler İçin)

Eğer tüm veritabanları tek seferde deploy edilecekse `master_deploy.sql` kullanılabilir. Not: Bu script içinde hangi DB'leri bağlandığını ve credential'ları kontrol ediniz.

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d postgres -f master_deploy.sql
```

---

## Deployment Modes (Core Database)

Core veritabanı için 3 farklı deployment senaryosu bulunur:

1. **Base Deployment (`deploy_core.sql`)**:
    - Şema, fonksiyon, trigger ve temel lookup verilerini (ülke, para birimi vb.) içerir.
    - Default geliştirme verileriyle gelir.

    ```bash
    psql -h 207.180.241.230 -p 5433 -U postgres -d core -f deploy_core.sql
    ```

2. **Staging Deployment (`deploy_core_staging.sql`)**:
    - Base deployment üzerine, test amaçlı client, kullanıcı ve menü verilerini (`staging_seed`) ekler.
    - `core` veritabanını sıfırlar ve yeniden kurar.

    ```bash
    psql -h 207.180.241.230 -p 5433 -U postgres -d core -f deploy_core_staging.sql
    ```

3. **Production Deployment (`deploy_core_production.sql`)**:
    - Base deployment üzerine, **Production** ortamı için gerekli temiz veriyi (`production_seed`) yazar.
    - Sadece "Sortis One Platform" ana şirketini ve tek bir "Super Admin" kullanıcısını oluşturur.
    - `core` veritabanını sıfırlar ve yeniden kurar.
    ```bash
    psql -h 207.180.241.230 -p 5433 -U postgres -d core -f deploy_core_production.sql
    ```

---

## Yeni Client Provisioning (deploy_new_client.ps1)

Yeni bir client oluşturmak için `deploy_new_client.ps1` script'i kullanılır. Bu script, client için gerekli **5 veritabanını** otomatik olarak oluşturur ve deploy eder:

| Veritabanı | Deploy Dosyası | Açıklama |
|---|---|---|
| `client_{code}` | `deploy_client.sql` | Ana client: oyuncular, cüzdanlar, işlemler |
| `client_log_{code}` | `deploy_client_log.sql` | Aktivite ve işlem logları |
| `client_audit_{code}` | `deploy_client_audit.sql` | Denetim kayıtları |
| `client_report_{code}` | `deploy_client_report.sql` | Raporlar ve istatistikler |
| `client_affiliate_{code}` | `deploy_client_affiliate.sql` | Affiliate plugin verileri |

**Temel Kullanım**

```powershell
# Yeni client oluştur (ör: client_acme, client_log_acme, ...)
.\deploy_new_client.ps1 -ClientCode "acme"

# Numerik kod ile
.\deploy_new_client.ps1 -ClientCode "1"
```

**Dry Run (Önce Kontrol)**

```powershell
# Bağlantı ve dosya kontrolü yap, deploy etme
.\deploy_new_client.ps1 -ClientCode "acme" -Dry
```

**Mevcut DB'leri Atlama**

```powershell
# Zaten varolan DB'leri atla, eksikleri oluştur
.\deploy_new_client.ps1 -ClientCode "acme" -SkipIfExists
```

**Hata Durumunda Rollback**

Herhangi bir adımda hata oluşursa, o ana kadar oluşturulan tüm veritabanları otomatik olarak silinir (rollback).

**Reset (Sil + Yeniden Oluştur)**

```powershell
# Tüm client DB'lerini sil ve sıfırdan oluştur
.\deploy_new_client.ps1 -ClientCode "acme" -Reset

# Önce ne olacağını gör
.\deploy_new_client.ps1 -ClientCode "acme" -Reset -Dry
```

**Provisioning Sonrası Adımlar**

1. Backend'de client kaydını oluştur (core DB)
2. Client seed verilerini backend üzerinden yükle
3. Connection string'i yapılandır

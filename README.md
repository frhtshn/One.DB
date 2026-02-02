# NucleoDB

## Kurulacak VS Code Extension'ları

1. **SQLTools**  
   Publisher: Matheus Teixeira

2. **SQLTools PostgreSQL/Cockroach Driver**  
   Publisher: Matheus Teixeira

Bu extension'larla db'ye bağlanılır. Daha sonra bir script yazıldığında "Run Script" yapılarak direk deploy alınır.

---

## Dokümantasyon

Detaylı mimari ve yapı dokümantasyonu için:

| Dosya                                                      | Açıklama                                 |
| ---------------------------------------------------------- | ---------------------------------------- |
| [PROJECT_OVERVIEW.md](.docs/PROJECT_OVERVIEW.md)           | **Proje genel bakış ve büyük resim**     |
| [DATABASE_ARCHITECTURE.md](.docs/DATABASE_ARCHITECTURE.md) | Veritabanı mimarisi, şemalar ve tablolar |
| [DATABASE_FUNCTIONS.md](.docs/DATABASE_FUNCTIONS.md)       | Stored procedures ve trigger referansı   |
| [LOGSTRATEGY.md](.docs/LOGSTRATEGY.md)                     | Log, audit ve retention stratejisi       |

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

### 5. Deploy Tenant

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d tenant -f deploy_tenant.sql
```

### 6. Deploy Tenant Affiliate

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d tenant_affiliate -f deploy_tenant_affiliate.sql
```

### 7. Deploy Tenant Audit

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d tenant_audit -f deploy_tenant_audit.sql
```

### 8. Deploy Tenant Log

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d tenant_log -f deploy_tenant_log.sql
```

### 9. Deploy Tenant Report

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d tenant_report -f deploy_tenant_report.sql
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

2. **Staging Deployment (`deploy_core_staging.sql`)**:
    - Base deployment üzerine, test amaçlı tenant, kullanıcı ve menü verilerini (`staging_seed`) ekler.
    - `core` veritabanını sıfırlar ve yeniden kurar.

3. **Production Deployment (`deploy_core_production.sql`)**:
    - Base deployment üzerine, **Production** ortamı için gerekli temiz veriyi (`production_seed`) yazar.
    - Sadece "Nucleo Platform" ana şirketini ve tek bir "Super Admin" kullanıcısını oluşturur.
    - `core` veritabanını sıfırlar ve yeniden kurar.

---

## Tenant Template Example

```sql
CREATE DATABASE tenant_ferhatbet WITH TEMPLATE tenant;
```

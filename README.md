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
| [DATABASE_ARCHITECTURE.md](.docs/DATABASE_ARCHITECTURE.md) | Veritabanı mimarisi, şemalar ve tablolar |
| [DATABASE_FUNCTIONS.md](.docs/DATABASE_FUNCTIONS.md)       | Stored procedures ve trigger referansı   |
| [LOGSTRATEGY.md](.docs/LOGSTRATEGY.md)                     | Log, audit ve retention stratejisi       |

---

## Local Server (Localhost)

```bash
set PGPASSWORD=sizin_şifre
```

### Create Database local

```bash
psql -h localhost -U postgres -d postgres -f create_dbs.sql
```

### Deploy Core

```bash
psql -h localhost -U postgres -d core -f deploy_core.sql
```

### Deploy Tenant

```bash
psql -h localhost -U postgres -d tenant -f deploy_tenant.sql
```

### Deploy Core Log

```bash
psql -h localhost -U postgres -d core_log -f deploy_core_log.sql
```

### Deploy Core Audit

```bash
psql -h localhost -U postgres -d core_audit -f deploy_core_audit.sql
```

### Deploy Bonus

```bash
psql -h localhost -U postgres -d bonus -f deploy_bonus.sql
```

### Deploy Tenant Affiliate

```bash
psql -h localhost -U postgres -d tenant_affiliate -f deploy_tenant_affiliate.sql
```

---

## Deploy Core - Beta Server

```bash
set PGPASSWORD=StrongPass123!
psql -h 155.133.22.97 -U admin -d core -f deploy_core.sql
```

---

## New Beta Server

```bash
set PGPASSWORD=NucleoPostgres2026
```

### Create Database beta

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d postgres -f create_dbs.sql
```

### Deploy Core

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d core -f deploy_core.sql
```

### Deploy Tenant

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d tenant -f deploy_tenant.sql
```

### Deploy Core Log

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d core_log -f deploy_core_log.sql
```

### Deploy Core Audit

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d core_audit -f deploy_core_audit.sql
```

### Deploy Bonus

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d bonus -f deploy_bonus.sql
```

### Deploy Tenant Affiliate

```bash
psql -h 207.180.241.230 -p 5433 -U postgres -d tenant_affiliate -f deploy_tenant_affiliate.sql
```

---

## Tenant Template Example

```sql
CREATE DATABASE tenant_ferhatbet WITH TEMPLATE tenant;
```

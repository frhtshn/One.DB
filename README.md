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
| [LOGSTRATEGY.md](.docs/LOGSTRATEGY.md)                     | Log, audit ve retention stratejisi       |

---

## Deploy the Schema SQL File to the Core Database

```bash
set PGPASSWORD=sizin_şifre
psql -h localhost -U postgres -d core -f deploy_core.sql
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

### Create Database

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

---

## Tenant Template Example

```sql
CREATE DATABASE tenant_ferhatbet WITH TEMPLATE tenant;
```

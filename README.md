// kurulacak vs extension'lar:

1. SQLTools
   Publisher: Matheus Teixeira

2. SQLTools PostgreSQL/Cockroach Driver
   Publisher: Matheus Teixeira

Bu extension'larla db'ye bağlanılır. daha sonra bir script yazıldığında "run script" yapılarak direk deploy alınır.

---

// Dump the schema of the core database to a SQL file

set PGPASSWORD=sizin şifre

"pg_dump.exe" -h localhost -p 5432 -U postgres -d core --schema-only --no-owner --no-privileges --format=p --encoding=UTF8 > "C:\Projects\Git\nucleoDb\schema.sql"

// Deploy the schema SQL file to the core database

set PGPASSWORD=sizin şifre

psql -h localhost -U postgres -d core -f deploy_core.sql

// Deploy Core -> Beta Server

set PGPASSWORD=StrongPass123!

psql -h 155.133.22.97 -U admin -d core -f deploy_core.sql

// new beta server
set PGPASSWORD=NucleoPostgres2026

// create db
psql -h 207.180.241.230 -p 5433 -U postgres -d postgres -f create_dbs.sql

// Deploy core
psql -h 207.180.241.230 -p 5433 -U postgres -d core -f deploy_core.sql

// Deploy tenant
psql -h 207.180.241.230 -p 5433 -U postgres -d tenant -f deploy_tenant.sql

// tenant template example
-- CREATE DATABASE tenant_ferhatbet WITH TEMPLATE tenant;

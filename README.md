// kurulacak vs extension'lar: 

1. SQLTools 
Publisher: Matheus Teixeira

2. SQLTools PostgreSQL/Cockroach Driver
Publisher: Matheus Teixeira

Bu extension'larla db'ye bağlanılır. daha sonra bir script yazıldığında "run script" yapılarak direk deploy alınır. 

----------------------------------------------------


// Dump the schema of the core database to a SQL file

set PGPASSWORD=sizin şifre

"C:\Program Files\PostgreSQL\17\bin\pg_dump.exe" -h localhost -p 5432 -U postgres -d core --schema-only --no-owner --no-privileges --format=p --encoding=UTF8 > "C:\Projects\Git\nucleoDb\schema.sql"

// Deploy the schema SQL file to the core database

set PGPASSWORD=sizin şifre

"C:\Program Files\PostgreSQL\17\bin\psql.exe" -h localhost -U postgres -d core -f deploy_core.sql

// Deploy Core -> Beta Server

set PGPASSWORD=StrongPass123!

"C:\Program Files\PostgreSQL\17\bin\psql.exe" -h 155.133.22.97 -U admin -d core -f deploy_core.sql

// Deploy Tenant 

set PGPASSWORD=StrongPass123!

"C:\Program Files\PostgreSQL\17\bin\psql.exe" -h 155.133.22.97 -U admin -d tenant_ -f deploy_tenant.sql


// tenant_ template example
-- CREATE DATABASE tenant_ferhatbet WITH TEMPLATE tenant_;

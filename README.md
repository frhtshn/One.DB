// kurulacak vs extension'lar: 

1. SQLTools 
Publisher: Matheus Teixeira

2. SQLTools PostgreSQL/Cockroach Driver
Publisher: Matheus Teixeira

Bu extension'larla db'ye bağlanılır. daha sonra bir sql yazıldığında "run script" yapılarak direk deploy alınır. 

----------------------------------------------------


// Dump the schema of the maindb database to a SQL file

set PGPASSWORD=sizin şifre

"C:\Program Files\PostgreSQL\17\bin\pg_dump.exe" -h localhost -p 5432 -U postgres -d maindb --schema-only --no-owner --no-privileges --format=p --encoding=UTF8 > "C:\Projects\Git\nucleoDb\schema.sql"

// Deploy the schema SQL file to the maindb database

set PGPASSWORD=sizin şifre

"C:\Program Files\PostgreSQL\17\bin\psql.exe" -h localhost -U postgres -d maindb -f db\deploy_maindb.sql

// Deploy all core 

set PGPASSWORD=sizin şifre

"C:\Program Files\PostgreSQL\17\bin\psql.exe"-U postgres -d core -f deploy_core.sql
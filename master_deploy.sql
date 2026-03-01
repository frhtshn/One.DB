-- master_deploy.sql
-- Tüm veritabanı ve şema deploy işlemlerini sıralı şekilde tetikler


\i create_dbs.sql

\i deploy_analytics.sql
\i deploy_bonus.sql
\i deploy_core.sql
\i deploy_finance.sql
\i deploy_game.sql
\i deploy_client.sql

-- Sonuç
COMMIT;

-- master_deploy.sql
-- Tüm veritabanı ve şema deploy işlemlerini sıralı şekilde tetikler


\i create_dbs.sql

\i deploy_analytics.sql
\i deploy_bonus.sql
\i deploy_core.sql
\i deploy_core_audit.sql
\i deploy_core_log.sql
\i deploy_core_report.sql
\i deploy_finance.sql
\i deploy_finance_log.sql
\i deploy_game.sql
\i deploy_game_log.sql
\i deploy_tenant.sql
\i deploy_tenant_audit.sql
\i deploy_tenant_log.sql
\i deploy_tenant_report.sql
\i deploy_tenant_affiliate.sql

-- Sonuç
COMMIT;
